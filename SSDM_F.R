library(SSDM)
library(raster)
library(rgdal)
library(maxent)
library(foreach)
library(doSNOW)
library(dismo)

# Set working directories and file paths
setwd("//Filer01/se/Action/GEODATA/SouthAmerica/PROJECTS/Guyana Priority Conservation Areas/Species_Data/cleaned/Amphibians/csv")
env_path <- "//clark/geodata/SouthAmerica/PROJECTS/Guyana Priority Conservation Areas/GIS_Data/PROCESSING_final_env"

# Import full species list
data.amphibians <- read.csv("//clark/geodata/SouthAmerica/PROJECTS/Guyana Priority Conservation Areas/Species_Data/cleaned/Amphibians/csv/gbif_amphibians.csv")
head(data.amphibians)

# Load environmental variables (rasters/categorical .shp) and project to common ProjSys
env_stack <- load_var(env_path, files = NULL, tmp = TRUE) #format = c(".asc", ".tif")
  proj4string(env_stack) <- CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")
  plot(env_stack)
  
# Import occurance data (you can import all species and subset in the modelling step)
amph.occo <- load_occ(path = '//clark/geodata/SouthAmerica/PROJECTS/Guyana Priority Conservation Areas/Species_Data/cleaned/Amphibians/csv', env_stack,
                Xcol = "LONGITUDE", Ycol = "LATITUDE",
                file = 'amph_test.csv', sep = ',', verbose = FALSE)
head(amph.occo)

# Stacked Species Distribution Model

amph.stack <- stack_modelling(c('RF', 'SVM'),
                              amph.occo,
                              env_stack,
                              rep = 1,
                              Xcol = 'LONGITUDE',
                              Ycol = 'LATITUDE',
                              Spcol = 'SPECIES',
                              method = "pSSDM",
                              verbose = TRUE)

# Plot individual
plot(amph.stack@enms$`Anomaloglossus roraima.Ensemble.SDM`@binary)
points(amph.occo$LONGITUDE, amph.occo$LATITUDE, col="red", cex=.6)
plot(SSDM@diversity.map, main = 'SSDM')
                          
plot(ens.adelophryne@projection, main = 'ESDM\nfor Malabricus\nwith RF, SVM, GLM algorithms')
plot(ens.adelophryne@binary, main = 'ESDM\nfor Malabricus\nwith RF, SVM, GLM algorithms')

knitr::kable(ens.adelophryne@evaluation)


#--- WRITE PLOTS/MAPS TO FILE ---#
proj.ens.ocellaris <- writeRaster(ens.ocellaris@projection, filename="proj_ens_ocellaris.tif", format="GTiff", overwrite=TRUE)
points(occ.afinis$LONGITUDE, occ.afinis$LATITUDE, col="red", cex=.6)
bin.ens.ocellaris <- writeRaster(ens.ocellaris@binary, filename="bin_ocellaris.tif", format="GTiff", overwrite=TRUE)

#SINGLE VS. 2x3 Laout
relay <- par(mfrow=c(1,1))
layout <- par(mfrow=c(2,3))

#Continuous Maps w/ Points
plot(ens.ocellaris@projection, main="OCELLARIS\n \nEnsemble used: RF, SVM, GLM, MAXENT, ANN")
   points(occ.ocellaris$LONGITUDE, occ.ocellaris$LATITUDE, cex=0.6)
plot(ens.malabricus@projection, main="MALABRICUS\n \n")
   points(occ.malabricus$LONGITUDE, occ.malabricus$LATITUDE, cex=0.6)
plot(ens.afinis@projection, main="AFINIS\n \n")
   points(occ.afinis$LONGITUDE, occ.afinis$LATITUDE, cex=0.6)

#Binary Maps w/ points
plot(ens.ocellaris@binary, main="OCELLARIS\nBinary Presence/Absence")
    points(occ.ocellaris$LONGITUDE, occ.ocellaris$LATITUDE, cex=0.6)
plot(ens.malabricus@binary, main="MALABRICUS\n")
    points(occ.malabricus$LONGITUDE, occ.malabricus$LATITUDE, cex=0.6)
plot(ens.afinis@binary, main="AFINIS\n")
    points(occ.afinis$LONGITUDE, occ.afinis$LATITUDE, cex=0.6)

#dev.off()

##----EVALUATING MODELS----##
##--VERY REDUNDANT--##

occo <- load_occ(path = '//clark/geodata/SouthAmerica/PROJECTS/Guyana Priority Conservation Areas/Species_Data/cleaned/Fishes/csv', env_stack,
                 Xcol = "LONG", Ycol = "LAT",
                 file = 'fish_test.csv', sep = ',', verbose = FALSE)

TAK.ESDM <- ensemble_modelling('all', subset(occo, occo$SPECIES == 'Geophagus sp takutu'),
                              env_stack, rep = 1, Xcol = 'LONG', Ycol = 'LAT',
                              ensemble.thresh = c(0.8), verbose = FALSE)
plot(TAK.ESDM@projection, main = 'ESDM\nfor TAK\nwith ALL')
plot(TAK.ESDM@binary, main = 'ESDM\nfor TAK\nwith A::')
points(occo$LONG, occo$LAT)
plot(TAK.ESDM)

#
HT.ESDM <- ensemble_modelling('all', subset(occo, occo$SPECIES == 'Hypostomus taphorni'),
                              env_stack, rep = 1, Xcol = 'LONG', Ycol = 'LAT',
                              ensemble.thresh = c(0.6), verbose = FALSE)
plot(HT.ESDM@projection, main = 'ESDM\nfor Hypostomus taphorni\nwith RF, SVM')
points(HT$LONG, HT$LAT)

#
MG.ESDM <- ensemble_modelling(c('RF', 'SVM'), subset(occo, occo$SPECIES == 'Mesonauta guyanae'),
                              env_stack, rep = 1, Xcol = 'LONG', Ycol = 'LAT',
                              ensemble.thresh = c(0.6), verbose = FALSE)
plot(MG.ESDM@projection, main = 'ESDM\nfor Mesonauta guyanae\nwith RF, SVM')
points(MG$LONG, MG$LAT)

#
PH.ESDM <- ensemble_modelling(c('RF', 'SVM'), subset(occo, occo$SPECIES == 'Platydoras hancockii'),
                              env_stack, rep = 1, Xcol = 'LONG', Ycol = 'LAT',
                              ensemble.thresh = c(0.6), verbose = FALSE)
plot(PH.ESDM@projection, main = 'ESDM\nfor Platydoras hancockii\nwith RF, SVM')
points(PH$LONG, PH$LAT)


#---For loop to iterate through unique species names to run models at once---#

n.Species <- unique(amph.occo$SPECIES)
s.List <- list(n.Species)
occ <- dat[spe == spe][, -3]
m <- ensemble_modelling(c('RF', 'SVM'), amph.occo, env_stack, rep = 1, Xcol = 'LONGITUDE', Ycol = 'LATITUDE', verbose = TRUE)

for (i in 1:length(s.List)){
  print(s.List[[i]])
  for (i in s.List)
}

for (species in n.Species){
  print(i, data=amph.occo)
  m <- ensemble_modelling(c('RF', 'SVM'), amph.occo, env_stack, rep = 1, Xcol = 'LONGITUDE', Ycol = 'LATITUDE', verbose = TRUE)
  m(n.Species[[x]])
}
m(n.Species[[x]])

ESDM <- ensemble_modelling(c('RF', 'SVM', 'GLM'), subset(amph.occo, amph.occo$SPECIES == 'Adenomera lutzi'),
                             env_stack, rep = 1, Xcol = 'LONGITUDE', Ycol = 'LATITUDE',
                             ensemble.thresh = c(0.6), verbose = FALSE)

n.Species <- unique(amph.occo$SPECIES)
testfunc <- function(spe){

  oc <- amph.occo[spe == spe][, -3]
  ESDM <- ensemble_modelling(c('RF', 'SVM', 'GLM'),
                             amph.occo,
                             env_stack,
                             rep = 1,
                             Xcol = 'LONGITUDE', Ycol = 'LATITUDE',
                             ensemble.thresh = c(0.6), verbose = FALSE)
  r <- ESDM@projection
  return(r)
}
for(x in 1:20) {
  testfunc(n.Species[[x]])
}

----
  
cl <- makeCluster(3, "SOCK")
registerDoSNOW(cl)
run <- foreach(x = 1: length(n.Species), .packages = c("dismo")) %dopar%
{
  textfunc(n.Species[[x]])
}
stopCluster(cl)

fold <- kfold(occ, k=5)
occtest <- occ[fold == 1, ]
occtrain <- occ[fold != 1, ]
# stack all the outputs and name them
stack.out <- stack(maxent.runs)
names(stack.out) <- n.Species
stack.out
