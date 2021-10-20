library(imager)
library(shiny)
library(jpeg)
library(png)
library(shinydashboard)
library(shinyWidgets)
library(reticulate)

# Define any Python packages needed for the app here:
PYTHON_DEPENDENCIES = c('pip','numpy','opencv-python')

#######################server##################################
server <- shinyServer(function(input, output) {
  # ------------------ App virtualenv setup (Do not edit) ------------------- #
  virtualenv_dir = Sys.getenv('VIRTUALENV_NAME')
  python_path = Sys.getenv('PYTHON_PATH')
  # Create virtual env and install dependencies
  reticulate::virtualenv_create(envname = virtualenv_dir, python = python_path)
  reticulate::virtualenv_install(virtualenv_dir, packages = PYTHON_DEPENDENCIES,ignore_installed=TRUE)
  reticulate::use_virtualenv(virtualenv_dir, required = T)
  # ------------------ App server logic (Edit anything below) --------------- #
  output$originImage = renderImage({
    list(src = if (is.null(input$file1)) {
      '1.jpg'
    } else {
      input$file1$datapath
    },
    title = "Original Image",
    withProgress(message = 'working', value = 0, {   
      step = 10
      for( i in 1:step){ 
        Sys.sleep(0.1)  
        incProgress(1/step, detail = paste(i, 'step working'))
      } 
    })
    )
  },
  deleteFile = FALSE)
  
  output$res =renderImage({
    list(src = if (is.null(input$file1)) {
      '2.jpg'
    }
    else {
      my <- import('detect')
      my$main(input$file1$datapath)
      'detection1.png'
    },
    title = "Original Image"
    )
  },
  deleteFile = FALSE)
}
)
#############################UI#############################
css <- "
.navbar-default {
  background-color: inherit;
  border: none;
}
"
body <- dashboardBody(
  fileInput('file1', 'Upload a PNG / JPEG File:'),
  fluidRow(),
  mainPanel(
    h3("Input Image"),
    tags$hr(),
    imageOutput("originImage", height = "auto"),
    tags$hr(),
    h3("What is this?"),
    tags$hr(),
    imageOutput("res", height = "auto"),
    tags$hr()
  )
)

ui <- shinyUI(
  fluidPage(
    includeCSS("bootstrap.css"),
    tags$head(tags$style(css)),
    setBackgroundColor(
      color = c("#F4FFFF","#F4FFFF"),
      gradient = "linear",
      direction = c("bottom","center")),
    includeCSS("bootstrap.css"),
    titlePanel(
      div(p(strong("DOG BREED CLASSIFICATION")),
          style = "color: #00A5FF"
      )
    ),
    body
  ))

#############################APP###############################
shinyApp(ui = ui, server = server)
