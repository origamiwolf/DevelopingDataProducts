# server.R
source("helper.R")
library(ggplot2)
library(tidyr)

# load and process cepheid data into long format
rawCeph <- read.csv("cepheids.csv")
cleanCeph <- gather(rawCeph,magVal,appMag,Min:Max)

shinyServer(function(input,output) {

  # use default distance to SMC to calculate absolute magnitude
  cephData <- reactive({
    processCephData(cleanCeph,input$smcDist)
  })

  cephFitsApp <- reactive({
    fitCephData(cleanCeph,"appMag")    
  })
    
  output$plot <- renderPlot({
    plotData<-cephData()

    # determine if plot is linear or log    
    if (input$plotAxis=="linear") {
      xPlot<-"Period"
      smoothForm<-"y~log10(x)"
    } else {
      xPlot<-"log10(Period)"
      smoothForm<-"y~x"
    }

    # determine if plot is for absolute or apparent magnitude
    if (input$magType=="appMag") {
      yPlot<-"appMag"
    } else {
      yPlot<-"absMag"
    }
    
    p <- ggplot(plotData,aes_string(xPlot,yPlot,col="magVal"))
    p <- p + geom_point()
    p <- p + scale_y_reverse()

    # determine whether to show regression lines
    if (input$showModels == TRUE) {
      p <- p+stat_smooth(method="lm", formula = smoothForm)
    }
    p
  })
  output$model <- renderText({
  })
})