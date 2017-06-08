#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

#install.packages(c("rjson",devtools"))
#library(devtools)
#install_github("trestletech/shinyTree")

library(shiny)

library(rjson)
library(shinyTree)

# By default, the file size limit is 5MB. It can be changed by
# setting this option. Here we'll raise limit to 9MB.
options(shiny.maxRequestSize = 250*1024^2)

#len <- do.call('c',sapply(json$file_data,"[[","read_lengths"))
jsondata <- fromJSON(file="../test_data/input.fofn.stats")
# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  #This function is responsible for loading in the selected file
  jsondata <- reactive({
    infile <- input$jsonfile$datapath
    if (is.null(infile)) {
      # User has not uploaded a file yet
      return(NULL)
    }
    print(infile)
    fromJSON(file=infile)
  })

  output$tree <- renderTree({
    jd <- jsondata()
    if (is.null(jd)){
      # Use has not uploaded a file yet
      return(list("NONE"=NULL))
    }
    f <- list("ALL"=lapply(jd$file_data,"[[","filename"))
    names(f$ALL) <- sapply(jd$file_data,"[[","cell_barcode")
    f
  })
  
  output$distPlot <- renderPlot({
    tree <- input$tree
    selected <- unlist(get_selected(tree, format = "slices"))
    print(selected)
     if (is.null(selected) |selected == "NONE"){
      hist(c(0))      
    } else{
      x <- jsondata()
      lens <- do.call('c',sapply(x$file_data,"[[","read_lengths"))
      # draw the histogram with the specified number of bins
      hist(lens, breaks = bins, col = 'darkgray', border = 'white')
    }
  })
  
})

