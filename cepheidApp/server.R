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

#   Not needed for now
#   cephFitsApp <- reactive({
#     fitCephData(cleanCeph,"appMag")    
#   })
    
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
    if (input$plotAxis=="linear") {
      xPlot<-"Period"
      smoothForm<-"y~log10(x)"
      plotLabels$x<-"Period (days)"
    } else {
      xPlot<-"log10(Period)"
      smoothForm<-"y~x"
      plotLabels$x<-"Log(Period/1 day)"
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
    p <- ggplot(plotData,aes_string(xPlot,yPlot,col="magVal"))
    p <- p + geom_point(size=3)
    
    # stellar magnitudes are traditionally shown in reverse order
    p <- p + scale_y_reverse()

    # add labels and use better colours
    p <- p + labs(plotLabels) + scale_colour_manual(
                                  values=c("#0072B2", "#D55E00")
                                )
    
    # determine whether to show regression lines
    if (input$showModels == TRUE) {
      p <- p+stat_smooth(method="lm", formula = smoothForm)
    }
    p
  })
  output$model <- renderText({
  })
})