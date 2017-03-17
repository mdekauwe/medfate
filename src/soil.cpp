#include <Rcpp.h>
using namespace Rcpp;


/**
 * Returns Soil water potential (in MPa)
 */
// [[Rcpp::export("soil.theta2psi")]]
double theta2psi(double clay, double sand, double theta) {
  double A = -0.1 * exp(-4.396 - (0.0715*clay)-(0.0004880*pow(sand,2)) - (0.00004285*pow(sand,2)*clay));
  double B = -3.140 - (0.00222*pow(clay,2)) - (0.00003484*pow(sand,2)*(clay));
  double psi = A*pow(theta,B);
  if(psi < -40.0) psi = -40.0;
  if(theta==0.0) psi = -40.0;
  return(psi);
}
/**
 *  psi - Soil water potential (in MPa)
 */
// [[Rcpp::export("soil.psi2theta")]]
double psi2theta(double clay, double sand, double psi) {
  double A = -0.1 * exp(-4.396 - (0.0715*clay)-(0.0004880*pow(sand,2)) - (0.00004285*pow(sand,2)*clay));
  double B = -3.140 - (0.00222*pow(clay,2)) - (0.00003484*pow(sand,2)*(clay));
  return(pow(psi/A, 1.0/B));
}

// [[Rcpp::export("soil.USDAType")]]
String soilUSDAType(double clay, double sand) {
  double silt = 100 - clay - sand;
  if((silt+1.5*clay)<15) return("Sand");
  else if(((silt+1.5*clay)>=15) & ((silt + 2.0*clay)<30)) return("Loamy sand");
  else if(((clay>=7) & (clay<20) & (sand>52) & ((silt + 2.0*clay)>=30)) | ((clay < 7) & (silt < 50) & ((silt + 2.0*clay)>=30))) return("Sandy loam");
  else if(((clay>=7) & (clay<27)) & ((silt>=28) & (silt<50)) & (sand<=52)) return("Loam");
  else if(((silt>=50) & ((clay>=12) & (clay<27))) | ((silt>=50) & (silt<80) & (clay <12))) return("Silt loam");
  else if((silt>=80) & (clay<12)) return("Silt");
  else if(((clay>=20) & (clay<35)) & (silt<28) & (sand>45)) return("Sandy clay loam");
  else if(((clay>=27) & (clay<40)) & ((sand>20) & (sand<=45))) return("Clay loam");
  else if(((clay>=27) & (clay<40)) & (sand<=20)) return("Silty clay loam");
  else if((clay>=35) & (sand>45)) return("Sandy clay");
  else if((clay>=40) & (silt>=40)) return("Silty clay");
  else if((clay>=40) & (sand<=45) &(silt<40)) return("Clay");
  return("Unknown");
}




/* 
 * Leij, F.J., Alves, W.J., Genuchten, M.T. Van, Williams, J.R., 1996. The UNSODA Unsaturated Soil Hydraulic Database User’s Manual Version 1.0.
 * Textural parameters (1 MPa = 0.00009804139432 cm)
 */
// [[Rcpp::export("soil.vanGenuchtenParams")]]
NumericVector vanGenuchtenParams(String soilType) {
  NumericVector vg(2,NA_REAL);
  if(soilType=="Sand") {vg[0]=1478.967; vg[1]=2.68;}
  else if(soilType=="Loamy sand") {vg[0]=1264.772; vg[1]=2.28;}
  else if(soilType=="Sandy loam") {vg[0]=764.983; vg[1]=1.89;}
  else if(soilType=="Loam") {vg[0]=367.1918; vg[1]=1.56;}
  else if(soilType=="Silt") {vg[0]=163.1964; vg[1]=1.37;}
  else if(soilType=="Silt loam") {vg[0]=203.9955; vg[1]=1.41;}
  else if(soilType=="Sandy clay loam") {vg[0]=601.7866; vg[1]=1.48;}
  else if(soilType=="Clay loam") {vg[0]=193.7957; vg[1]=1.31;}
  else if(soilType=="Silty clay loam") {vg[0]=101.9977; vg[1]=1.23;}
  else if(soilType=="Sandy clay") {vg[0]=275.3939; vg[1]=1.23;}
  else if(soilType=="Silty clay") {vg[0]=50.99887; vg[1]=1.09;}
  else if(soilType=="Clay") {vg[0]=81.59819; vg[1]=1.09;}
  return(vg);
}

// [[Rcpp::export("soil")]]
List soil(List SoilParams, NumericVector W = NumericVector::create(1.0)) {
  double SoilDepth = 0.0;
  NumericVector dVec = SoilParams["widths"];
  int nlayers = dVec.size();

  if(W.size()==1) {
    double w0 = W[0];
    W = NumericVector(nlayers);
    for(int l=0;l<nlayers;l++) W[l] = w0; 
  }
  //Soil parameters related to texture
  NumericVector clay = SoilParams["clay"];
  NumericVector sand = SoilParams["sand"];
  NumericVector macro = SoilParams["macro"];
  NumericVector rfc = SoilParams["rfc"];


  NumericVector SoilPRFC(nlayers);
  NumericVector Theta_FC(nlayers);
  NumericVector Water_FC(nlayers);
  NumericVector psi(nlayers);
  CharacterVector usda_Type(nlayers);
  NumericVector VG_alpha(nlayers);
  NumericVector VG_n(nlayers);
  for(int l=0;l<nlayers;l++) {
    SoilPRFC[l] = 1.0-(rfc[l]/100.0);
    Theta_FC[l] = psi2theta(clay[l], sand[l], -0.033); //FC to -33 kPa = -0.033 MPa
    Water_FC[l] =dVec[l]*Theta_FC[l]*SoilPRFC[l];
    usda_Type[l] = soilUSDAType(clay[l],sand[l]);
    psi[l] = theta2psi(clay[l], sand[l], W[l]*Theta_FC[l]);
    NumericVector vgl = vanGenuchtenParams(usda_Type[l]);
    VG_alpha[l] = vgl[0];
    VG_n[l] = vgl[1];
    SoilDepth +=dVec[l];
  }
  double Ssoil = Water_FC[0];
  List l = List::create(_["SoilDepth"] = SoilDepth,
                      _["W"] = W, _["psi"] = psi, _["Ksoil"] = SoilParams["Ksoil"], _["Gsoil"] = SoilParams["Gsoil"],
                      _["Ssoil"] = Ssoil,
                      _["dVec"] = dVec,
                      _["sand"] = sand, _["clay"] = clay,
                      _["usda_Type"] = usda_Type,
                      _["VG_alpha"] = VG_alpha,_["VG_n"] = VG_n, 
                      _["macro"] = macro, _["rfc"] = rfc,
                      _["Theta_FC"] = Theta_FC, _["Water_FC"] = Water_FC);
  l.attr("class") = CharacterVector::create("soil","list");
  return(l);
}