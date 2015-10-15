# helper.R

# helper functions
# distance in light years
# conversion 1 parsec = 3.26156 ly

parsec <- 3.26156

absMag <- function(appMag,distObj=10*parsec) {
  return (appMag-5*(log10(distObj/parsec)-1))
}

appMag <- function(absMag,distObj=10*parsec) {
  return (absMag+5*(log10(distObj/parsec)-1))
}

distObj <- function(absMag,appMag) {
  return (parsec*(10^(((appMag-absMag)/5)+1)))
}

processCephData <- function(cephData, distance) {
  cephData$absMag <- absMag(cephData$appMag,distance)
  return (cephData)
}

fitCephData <- function(cephData,magType="appMag") {
  fitMax <- lm(log10(Period)~magType,data=cephData[cephData$magVal=="Max",])
  fitMin <- lm(log10(Period)~magType,data=cephData[cephData$magVal=="Min",])  
  return (list(fitMax,fitMin)) 
}