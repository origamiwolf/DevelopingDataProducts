#ui.R

shinyUI(fluidPage(
  titlePanel("Cepheid Period-Luminosity Relationship"),
  tabsetPanel(
    tabPanel("Introduction",
      fluidRow(includeHTML("introText.html"))
    ),
    tabPanel("Data",
        fluidRow(includeHTML("dataTableText.html")),
        fluidRow(dataTableOutput(outputId="cepheidDataTable"))        
    ),
    tabPanel("Plot",
      sidebarLayout(
        sidebarPanel(
          tags$div(title="Slide to adjust distance to Small Magellanic Cloud",
            sliderInput("smcDist", 
                      "Distance to Small Magellanic Cloud (in units of kilo light years)",
                      min = 190,
                      max = 210,
                      value = 200,
                      step = 0.5)),
          br(),
          tags$div(title="Display period axis in linear or logarithmic scale",
            radioButtons("plotAxis","Select axis type:",
                       c("Linear" = "linear",
                         "Logarithmic" = "log")
          )),
          br(),
          tags$div(title="Display stars apparent or absolute magnitude",
            radioButtons("magType","Display:",
                       c("Apparent Magnitude" = "appMag",
                       "Absolute Magnitude" = "absMag")
          )),
          br(),
          tags$div(title="Display model fits of period vs magnitude",
            checkboxInput("showModels","Display regression lines?")
          )),
          mainPanel(plotOutput("plot",hover=hoverOpts(id="plotHover")),
                    htmlOutput("starInfo")            
          )
      )),
    tabPanel("Predictions",
      fluidRow(includeHTML("predictText.html")),
      fluidRow(
        column(4,wellPanel(title="Cepheid Observation Data",
          tags$div(title="Fill in the period of the Cepheid variable in days",
            numericInput("userPeriod","Period of Cepheid variable in days",
            value=15,step=0.5)),
          tags$div(title="Fill in the maximum apparent magnitude of the Cepheid variable",
            numericInput("userAppMagMax","Maximum Apparent Magnitude",
            value=14,step=0.5)),
          tags$div(title="Fill in the minimum apparent magnitude of the Cepheid variable",
            numericInput("userAppMagMin","Minimum Apparent Magnitude",
            value=15,step=0.5))
        )),
        column(6,wellPanel(title="Model results:",       
          htmlOutput("predictText")
        ))
      )
    ),
    tabPanel("Help",
      fluidRow(includeHTML("helpText.html")))
  )
))