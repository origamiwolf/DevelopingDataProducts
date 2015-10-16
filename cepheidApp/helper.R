# helper.R

# helper functions
# distance in light years
# conversion 1 parsec = 3.26156 ly

parsec <- 3.26156

absMag <- function(appMag,distObj=10*parsec) {
  absMag <-appMag-5*(log10(distObj/parsec)-1)
  return (round(absMag,1))
}

appMag <- function(absMag,distObj=10*parsec) {
  appMag <-absMag+5*(log10(distObj/parsec)-1)
  return (round(appMag,1))
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

getStarData <- function(cephData, H) {
  starData <- list(cephData[cephData$H == H,][1,1],
                cephData[cephData$H == H,][1,3],
                cephData[cephData$H == H & cephData$magVal=="Min",][1,5],
                cephData[cephData$H == H & cephData$magVal=="Min",][1,6],
                cephData[cephData$H == H & cephData$magVal=="Max",][1,5],
                cephData[cephData$H == H & cephData$magVal=="Max",][1,6]
              )
  return (starData)
}