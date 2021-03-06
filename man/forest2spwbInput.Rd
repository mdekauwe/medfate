\encoding{UTF-8}
\name{modelInput}
\alias{forest2aboveground}
\alias{forest2belowground}
\alias{forest2growthInput}
\alias{forest2spwbInput}
\alias{growthInput}
\alias{spwbInput}

\title{
Input for simulation models
}

\description{
Functions \code{forest2spwbInput} and \code{forest2growthInput} take an object of class \code{\link{forest}} and calculate input data for functions \code{\link{spwb}}, \code{\link{pwb}} and \code{\link{growth}}, respectively. Functions \code{spwbInput} and \code{growthInput} do the same but starting from different input data. Function \code{forest2aboveground} calculates aboveground variables that may be used in \code{spwbInput} and \code{growthInput} functions. Function \code{forest2belowground} calculates belowground fine root distribution.
}
\usage{
forest2aboveground(x, SpParams, gdd = NA, mode = "MED")
forest2belowground(x, soil)
forest2growthInput(x, soil, SpParams, control)
forest2spwbInput(x, soil, SpParams, control, mode = "MED")
growthInput(above,  Z50, Z95, soil, SpParams, control)
spwbInput(above,  Z50, Z95, soil, SpParams, control)
}
\arguments{
  \item{x}{An object of class \code{\link{forest}}.}
  \item{SpParams}{A data frame with species parameters (see \code{\link{SpParamsMED}} and \code{\link{SpParamsMED}}).}
  \item{gdd}{Growth degree days to account for leaf phenology effects (in Celsius). This should be left \code{NA} in most applications.}
  \item{mode}{Calculation mode, either "MED" or "US".}
  \item{soil}{An object of class \code{\link{soil}}.}
  \item{control}{A list with default control parameters (see \code{\link{defaultControl}}).}
  \item{above}{A data frame with aboveground plant information (see the return value of \code{forest2aboveground} below). In the case of \code{spwbInput} the variables should include \code{SP}, \code{N}, \code{LAI_live}, \code{LAI_dead}, \code{H} and \code{CR}. In the case of \code{growthInput} variables should include \code{DBH} and \code{Cover}. }
  \item{Z50, Z95}{Numeric vectors with cohort depths (in mm) corresponding to 50\% and 95\% of fine roots.}
}
\details{
Functions \code{forest2spwbInput} and \code{forest2abovegroundInput} extracts height and species identity from plant cohorts of \code{x}, and calculate leaf area index and crown ratio.\code{forest2spwbInput} also calculates the distribution of fine roots across soil. Both \code{forest2spwbInput} and \code{spwbInput} find parameter values for each plant cohort according to the parameters of its species as specified in \code{SpParams}. If \code{control$transpirationMode = "Sperry"} the functions also estimate the maximum conductance of rhizosphere, root xylem and stem xylem elements.
}
\value{
Function \code{forest2aboveground()} returns a data frame with the following columns (rows are identified as specified by function \code{\link{plant_ID}}):
\itemize{
  \item{\code{SP}: Species identity (an integer) (first species is 0).}
  \item{\code{N}: Cohort density (ind/ha) (see function \code{\link{plant_density}}).}
  \item{\code{DBH}: Tree diameter at breast height (cm).}
  \item{\code{H}: Plant total height (cm).}
  \item{\code{CR}: Crown ratio (crown length to total height) (between 0 and 1).}
  \item{\code{LAI_live}: Live leaf area index (m2/m2) (one-side leaf area relative to plot area), includes leaves in winter dormant buds.}
  \item{\code{LAI_expanded}: Leaf area index of expanded leaves (m2/m2) (one-side leaf area relative to plot area).}
  \item{\code{LAI_dead}: Dead leaf area index (m2/m2) (one-side leaf area relative to plot area).}
}

Functions \code{forest2spwbInput()} and \code{spwbInput()} return a list of class \code{spwbInput} with the following elements (rows of data frames are identified as specified by function \code{\link{plant_ID}}):
\itemize{
  \item{\code{control}: List with control parameters (see \code{\link{defaultControl}}).}
  \item{\code{canopy}: A list of stand-level state variables.}
  \item{\code{cohorts}: A data frame with cohort information, with columns \code{SP} and \code{Name}.}
  \item{\code{above}: A data frame with columns  \code{H}, \code{CR} and \code{LAI} (see function \code{forest2aboveground}).}
  \item{\code{below}: A data frame with columns \code{Z50}, \code{Z95}.  If \code{control$transpirationMode = "Sperry"} additional columns are \code{fineRootBiomass} and \code{coarseRootSoilVolume}.}
  \item{\code{belowLayers}: A list. If \code{control$transpirationMode = "Granier"} it contains elements: 
     \itemize{
        \item{\code{V}: A matrix with the proportion of fine roots of each cohort (in rows) in each soil layer (in columns).}
        \item{\code{L}: A matrix with the length of coarse roots of each cohort (in rows) in each soil layer (in columns).}
        \item{\code{Wpool}: A matrix with the soil moisture relative to field capacity around the rhizosphere of each cohort (in rows) in each soil layer (in columns).}
     }
     If \code{control$transpirationMode = "Sperry"} there are the following additional elements:
     \itemize{
        \item{\code{VGrhizo_kmax}: A matrix with maximum rhizosphere conductance values of each cohort (in rows) in each soil layer (in columns).}
        \item{\code{VGroot_kmax}: A matrix with maximum root xylem conductance values of each cohort (in rows) in each soil layer (in columns).}
        \item{\code{RhizoPsi}: A matrix with the water potential around the rhizosphere of each cohort (in rows) in each soil layer (in columns).}
     }
  }
  \item{\code{paramsPhenology}: A data frame with leaf phenology parameters:
     \itemize{
       \item{\code{Sgdd}: Growth degree days needed for leaf budburst (for winter decideous species).}
     }
  }
  \item{\code{paramsAnatomy}: A data frame with plant anatomy parameters for each cohort (only if \code{control$transpirationMode = "Sperry"}):
     \itemize{
       \item{\code{Hmax}: Maximum plant height (cm).}
       \item{\code{Hmed}: Median plant height (cm).}
       \item{\code{Al2As}: Leaf area to sapwood area ratio (in m2·m-2).}
       \item{\code{SLA}: Specific leaf area (mm2/mg = m2/kg).}
       \item{\code{LeafWidth}: Leaf width (in cm).}
       \item{\code{LeafDensity}: Density of leaf tissue (dry weight over volume).}
       \item{\code{WoodDensity}: Density of wood tissue (dry weight over volume).}
       \item{\code{FineRootDensity}: Density of fine root tissue (dry weight over volume).}
       \item{\code{SRL}: Specific Root length (cm·g-1).}
       \item{\code{RLD}: Root length density (cm·cm-3).}
       \item{\code{r635}: Ratio between the weight of leaves plus branches and the weight of leaves alone for branches of 6.35 mm.}
     }
  }
  \item{\code{paramsInterception}: A data frame with rain interception and light extinction parameters for each cohort:
     \itemize{
       \item{\code{kPAR}: PAR extinction coefficient.}
       \item{\code{g}: Canopy water retention capacity per LAI unit (mm/LAI).}
     }
     If \code{control$transpirationMode = "Sperry"} additional columns are:
     \itemize{
       \item{\code{gammaSWR}: Reflectance (albedo) coefficient for SWR .}
       \item{\code{alphaSWR}: Absorbance coefficient for SWR .}
     }
  }
  \item{\code{paramsTranspiration}: A data frame with parameters for transpiration and photosynthesis. If \code{control$transpirationMode = "Granier"}, columns are:
    \itemize{
       \item{\code{Psi_Extract}: Water potential corresponding to 50\% relative conductance (in MPa).}
       \item{\code{WUE}: Water use efficiency for carbon assimilation (g C/mm water).} 
       \item{\code{pRootDisc}: Proportion of whole-plant conductance leading to disconnection from soil.}
    }
    If \code{control$transpirationMode = "Sperry"} columns are:
    \itemize{
       \item{\code{Gwmax}: Maximum stomatal conductance to water vapor (in mol H2O·m-2·s-1).}
       \item{\code{Vmax298}: Maximum Rubisco carboxilation rate at 25ºC (in micromol CO2·s-1·m-2).}
       \item{\code{Jmax298}: Maximum rate of electron transport at 25ºC (in micromol photons·s-1·m-2).}
       \item{\code{Kmax_stemxylem}: Sapwood-specific hydraulic conductivity of stem xylem (in kg H2O·s-1·m-2).}
       \item{\code{Kmax_rootxylem}: Sapwood-specific hydraulic conductivity of root xylem (in kg H2O·s-1·m-2).}
       \item{\code{VCleaf_kmax}: Maximum leaf hydraulic conductance.}
       \item{\code{VCleaf_c}, \code{VCleaf_d}: Parameters of the leaf vulnerability curve.}
       \item{\code{VCstem_kmax}: Maximum stem xylem conductance.}
       \item{\code{VCstem_c}, \code{VCstem_d}: Parameters of the stem xylem vulnerability curve.}
       \item{\code{VCroot_c}, \code{VCroot_d}: Parameters of the root xylem vulnerability curve.}
       \item{\code{Plant_kmax}: Maximum whole-plant conductance.}
    }
  }
  \item{\code{paramsWaterStorage}: A data frame with plant water storage parameters for each cohort (only if \code{control$transpirationMode = "Sperry"}):
     \itemize{
       \item{\code{LeafPI0}: Osmotic potential at full turgor of leaves (MPa).}
       \item{\code{LeafEPS}: Modulus of elasticity (capacity of the cell wall to resist changes in volume in response to changes in turgor) of leaves (MPa).}
       \item{\code{LeafAF}: Apoplastic fraction (proportion of water outside the living cells) in leaves.}
       \item{\code{Vleaf}: Storage water capacity in leaves, per leaf area (L/m2).}
       \item{\code{StemPI0}: Osmotic potential at full turgor of symplastic xylem tissue (MPa).}
       \item{\code{StemEPS}: Modulus of elasticity (capacity of the cell wall to resist changes in volume in response to changes in turgor) of symplastic xylem tissue (Mpa).}
       \item{\code{StemAF}: Apoplastic fraction (proportion of water outside the living cells) in stem xylem.}
       \item{\code{Vstem}: Storage water capacity in sapwood, per leaf area (L/m2).}
     }
  }
  \item{\code{internalPhenology} and \code{internalWater}: data frames to store internal state variables.}
}
Functions \code{forest2growthInput} and \code{growthInput} return a list of class \code{growthInput} with the same elements as \code{spwbInput}, but with additional information. 
\itemize{
\item{Element \code{above} includes the following additional columns:
  \itemize{
    \item{\code{LA_live}: Live leaf area per individual (m2/ind).}
    \item{\code{LA_dead}: Dead leaf area per individual (m2/ind).}
    \item{\code{SA}: Live sapwood area per individual (cm2/ind).} 
  }
}
\item{\code{paramsGrowth}: A data frame with growth parameters for each cohort:
     \itemize{
    \item{\code{WoodC}: Wood carbon content per dry weight (g C /g dry).}
    \item{\code{RGRsapwoodmax}: Maximum relative growth rate (in basal area or sapwood area) (in cm2·cm-2).}
    \item{\code{fHDmin}: Minimum value of the height-to-diameter ratio (dimensionless).}
    \item{\code{fHDmax}: Maximum value of the height-to-diameter ratio (dimensionless).}
     }
}
\item{\code{paramsAllometry}: A data frame with allometric parameters for each cohort:
     \itemize{
    \item{\code{Aash}: Regression coefficient relating the square of shrub height with shrub area.}
    \item{\code{Absh}, \code{Bbsh}: Allometric coefficients relating phytovolume with dry weight of shrub individuals.}
    \item{\code{Acr}, \code{B1cr}, \code{B2cr}, \code{B3cr}, \code{C1cr}, \code{C2cr}: Regression coefficients used to calculate crown ratio of trees.}
    \item{\code{Acw}, \code{Bcw}: Regression coefficients used to calculated crown width of trees.}
     }
}
\item {\code{internalAllocation}: A data frame with internal allocation variables for each cohort:
     \itemize{
       \item{\code{allocationTarget}: Value of the allocation target variable.}
       \item{\code{leafAreaTarget}: Target leaf area (m2) per individual.}
       \item{\code{fineRootBiomassTarget}: Target fine root biomass (g dry) per individual (only if \code{transpirationMode = "Sperry"}).}
     }
}
\item{\code{internalCarbon} and \code{internalRings}: data structures to store other internal state variables.}
}

}
\author{
Miquel De \enc{Cáceres}{Caceres} Ainsa, CTFC
}
\seealso{\code{\link{resetInputs}}, \code{\link{spwb}}, \code{\link{soil}},  \code{\link{forest}}, \code{\link{SpParamsMED}}, \code{\link{defaultSoilParams}}, \code{\link{plant_ID}}}

\examples{
#Load example plot plant data
data(exampleforestMED)

#Default species parameterization
data(SpParamsMED)

# Aboveground parameters
above = forest2aboveground(exampleforestMED, SpParamsMED)
above

# Initialize soil with default soil params
examplesoil = soil(defaultSoilParams())

# Rooting depths
Z50 = c(exampleforestMED$treeData$Z50, exampleforestMED$shrubData$Z50)
Z95 = c(exampleforestMED$treeData$Z95, exampleforestMED$shrubData$Z95)

# Initialize control parameters
control = defaultControl()

# Prepare spwb input
spwbInput(above, Z50, Z95, examplesoil,SpParamsMED, control)

# When starting from an object of class 'forest' the whole process
# can be simplified:
forest2spwbInput(exampleforestMED, examplesoil, SpParamsMED, control)


# Prepare input for complex transpiration mode
control$transpirationMode = "Sperry"
forest2spwbInput(exampleforestMED,examplesoil,SpParamsMED, control)

}
