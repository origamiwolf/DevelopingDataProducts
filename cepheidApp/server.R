# server.R
source("helper.R")
library(ggplot2)
library(tidyr)

# load and process cepheid data into long format
rawCeph <- read.csv("cepheids.csv")
cleanCeph <- gather(rawCeph,magVal,appMag,Min:Max)

shinyServer(function(input,output) {

## computations
  
  # use default distance to SMC to calculate absolute magnitude
  cephData <- reactive({
    processCephData(cleanCeph,input$smcDist)
  })

  # model fits
  cephFits <- reactive({
    cephDataToFit<-cephData()
    fitCephData(cephDataToFit)    
  })
  
### Output for plot tab
  
  output$plot <- renderPlot({
    plotData<-cephData()

    # setup the label vectors
    plotLabels<-list(
                  title = "Cepheid Period-Magnitude Plot",
                  x = "Period (days)",
                  y = "Apparent Magnitude",
                  color = "Magnitude"
                )
    
    # determine if plot is linear or log
    plotLog <- FALSE
    if (input$plotAxis=="linear") {
      smoothForm<-"y~log10(x)"
      plotLabels$x<-"Period (days)"
      plotLog <- FALSE
    } else {
      smoothForm<-"y~x"
      plotLabels$x<-"Log(Period/1 day)"
      plotLog <- TRUE
    }

    # determine if plot is for absolute or apparent magnitude
    if (input$magType=="appMag") {
      yPlot<-"appMag"
      plotLabels$y<-"Apparent Magnitude"
    } else {
      yPlot<-"absMag"
      plotLabels$y<-"Absolute Magnitude"
    }

    # plot according to selected inputs    
    p <- ggplot(plotData,aes_string("Period",yPlot,col="magVal"))

    # if plotting log, then scale x axis
    if (plotLog) {
      p <- p + scale_x_log10()
    }
    # stellar magnitudes are traditionally shown in reverse order
    p <- p + scale_y_reverse()
    
    # set the size of the points
    p <- p + geom_point(size=3)

    # add labels and use better colours
    p <- p + labs(plotLabels) + scale_colour_manual(
                                  values=c("#0072B2", "#D55E00")
                                )
    
    # determine whether to show regression lines
    if (input$showModels == TRUE) {
       p <- p+geom_smooth(method="lm", formula = smoothForm)
    }
    p
  })
  
  output$starInfo <- renderUI({
    plotData<-cephData()
    star <- nearPoints(plotData,input$plotHover,maxpoints=1)
    starData <- getStarData(plotData,star$H)
    if (!anyNA(starData)) {
      starText <- paste("Star H Number: ", starData[[1]])
      starText <- c(starText, paste("Period:", starData[[2]], " days", collapse=" "))
      starText <- c(starText, paste("Apparent Magnitude:", 
                                    starData[[3]], "(Min) <--->",
                                    starData[[5]], "(Max)", collapse=" "))
      starText <- c(starText, paste("Absolute Magnitude:", 
                                    starData[[4]], "(Min) <--->",
                                    starData[[6]], "(Max)", collapse=" "))
      textOut <- paste(starText, collapse="<br>")
    } else {
      textOut <- ""
    }
    HTML(textOut)
  })

## output for data table tab

  output$cepheidDataTable <- renderDataTable({
    plotData<-subset(cephData(),select=H:appMag)
    plotData[order(plotData$Period),]
  })

## outputs for predictions tab
  output$predictText <- renderUI({
    modelFits <- cephFits()
    absMagMaxPredict<- predict(modelFits[[1]],data.frame("Period"=c(input$userPeriod)))
    absMagMinPredict<- predict(modelFits[[2]],data.frame("Period"=c(input$userPeriod)))

    distMaxPredict <- distObj(absMagMaxPredict,input$userAppMagMax)
    distMinPredict <- distObj(absMagMinPredict,input$userAppMagMin)

    predictText <- "Predicted absolute magnitude of Cepheid:"
    if(!is.na(absMagMaxPredict) && !is.infinite(absMagMaxPredict)) {
      predictText<-c(predictText,paste("Using maximum magnitude fit: <b>", round(absMagMaxPredict,2), "</b>"))
      predictText<-c(predictText,paste("Using minimum magnitude fit: <b>", round(absMagMinPredict,2), "</b>"))
    } else {
      predictText<-c(predictText,"A valid period is required for a prediction.")
    }
    
    predictText<-c(predictText,"<br>")
    
    predictText<-c(predictText,"Predicted distance to Cepheid:")
    if(!is.na(distMaxPredict) && (distMaxPredict > 0.5)) {
      predictText<-c(predictText,paste("Using maximum magnitude fit: <b>", round(distMaxPredict,0), "</b> kilo light years"))
      maxPredictValid<-TRUE
    } else {
      maxPredictValid<-FALSE
    }
    if(!is.na(distMinPredict) && (distMinPredict > 0.5)) {    
      predictText<-c(predictText,paste("Using minimum magnitude fit: <b>", round(distMinPredict,0), "</b> kilo light years"))
      minPredictValid<-TRUE
    } else {
      minPredictValid<-FALSE
    }
   
    if (!(maxPredictValid || minPredictValid)) {
      predictText<-c(predictText,"At least one valid magnitude is required for a prediction.")      
    } 
    
    textOut<-paste(predictText,collapse="<br>")
    HTML(textOut)
  })

})