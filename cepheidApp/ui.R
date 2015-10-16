#ui.R

shinyUI(fluidPage(
  titlePanel("Cepheid Period-Luminosity Relationship"),
  tabsetPanel(
    tabPanel("Introduction"),
    tabPanel("Data"),
    tabPanel("Plot",
      sidebarLayout(
        sidebarPanel(
          sliderInput("smcDist", 
                      "Distance to Small Magellanic Cloud (in units of kilo light years)",
                      min = 190,
                      max = 210,
                      value = 200,
                      step = 0.5),
          br(),
          radioButtons("plotAxis","Select axis type:",
                       c("Linear" = "linear",
                         "Logarithmic" = "log")
          ),
          br(),
          radioButtons("magType","Display:",
                       c("Apparent Magnitude" = "appMag",
                       "Absolute Magnitude" = "absMag")
          ),
          br(),
          checkboxInput("showModels","Display regression lines?")
          ),
          mainPanel(plotOutput("plot",hover=hoverOpts(id="plotHover")),
                    htmlOutput("starInfo")            
          )
      )),
    tabPanel("Predictions"),
    tabPanel("Help")
  )
))