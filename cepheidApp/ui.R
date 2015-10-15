#ui.R

shinyUI(fluidPage(
  titlePanel("Cepheid Period-Luminosity Relationship"),
  sidebarLayout(
    sidebarPanel(
      h2("Widgets go here"),
      sliderInput("smcDist", "Distance to Small Magellanic Cloud (in units of kilo light years)",
                  min = 190,
                  max = 210,
                  value = 200,
                  step = 0.5),
      br(),
      br(),
      radioButtons("plotAxis","Select axis type:",
                   c("Linear" = "linear",
                     "Logarithmic" = "log")
        ),
      br(),
      br(),
      radioButtons("magType","Display:",
                   c("Apparent Magnitude" = "appMag",
                     "Absolute Magnitude" = "absMag")
      ),
      br(),
      br(),
      checkboxInput("showModels","Display regression lines?")
    ),
    mainPanel(
      plotOutput("plot"),
      br(),
      textOutput("model")
    )
  )
))