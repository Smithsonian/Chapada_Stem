# ui
library(shiny)
library(plotly)

ui <- fixedPage(
  div(class = "quarto-title-banner",
      h1(class = "title", "Chapada Stem Data Dashboard")
  ),
  tags$head(
    tags$style(HTML("
    .quarto-title-banner {
      background-image: url('chapada.jpeg');
      background-size: cover;
      background-position: center;
      background-repeat: no-repeat;
      min-height: 200px;
      color: white;
      
      padding: 15px 30px;
      margin-bottom: 30px;
    }
    
    .sidebar {
      background-color: #f5f5f5; 
      padding: 20px; 
      border-radius: 8px; 
      min-height: 100%;
      border: 1px solid #e0e0e0;
    }
    
    .quarto-title-banner .title {
      text-shadow: 0 1px 3px rgba(0,0,0,0.6);
      margin: 0;
    }
                    "))
    ),
  
  fluidRow(
    column(3,
           class = "sidebar",
           h4("Plot Specifications"),
           dateInput('today', 'Today', 
                     min = "2025-09-18", 
                     max = Sys.Date(),
                     value = Sys.Date()),
           br(),
           numericInput('days_to_plot', 'Days of historical data to plot', 
                        0, 
                        round(as.numeric(difftime(Sys.Date(), "2025-09-19", units = "days"))),
                        value = 5),
           br(),
           radioButtons(
             "daily", label = "Time step", 
             choices  = c("Hourly", "Daily mean"), 
             selected = "Hourly"
           )
    ),
    
    column(9,
           tabsetPanel(
             tabPanel("Fluxes", plotlyOutput('plot_flux', height = 420)),
             tabPanel("Partitioned CO2", plotlyOutput('plot_part', height = 420)),
             tabPanel("Met", plotlyOutput('plot_met', height = 420)),
             tabPanel("Redox", plotlyOutput('plot_redox', height = 420)),
             tabPanel("Teros", plotlyOutput('plot_teros', height = 420)),
             tabPanel("BME", plotlyOutput('plot_bme', height = 420))
           )
    )
  ),
  
  tags$footer(
    style="background-color: #f2f2f2; padding: 1.2em 0; margin-top: 2em; text-align: center; color: #444; font-size: 0.9em;",
    "Funding for this project was provided by the United States National Science Foundation under Award # 2341407"
  )
)


# server
library(shiny)
library(tidyverse)
library(plotly)

theme_dash <- theme_bw() +
  theme(
    axis.title.x = element_blank(),
    axis.text.x = element_text(angle = 30, vjust = 1, hjust = 1),
    axis.title.y = element_text(margin = margin(r = 15)),
    legend.position = "bottom"
  )

server <- function(input, output, session) {
  
  color.vals=c("#F29559", "#F2B576","#F2D492", "#C1BE7E","#888F5C", "#4E603A", "#1F3829")
  color.gradient <- colorRampPalette(color.vals)(9)
  
  slopes_l0 <- read_csv("https://raw.githubusercontent.com/abbylewis/Chapada_flux_data/refs/heads/master/processed_data/L0.csv", show_col_types = F) %>%
    filter(!is.na(location), n>30) %>%
    mutate(TIMESTAMP = force_tz(TIMESTAMP, tzone = "Etc/GMT-3")) %>% 
    rename(chamber = Fluxing_Chamber) %>%
    mutate(type = case_when(
      chamber == 90~"Termites", 
      chamber %in% c(10,20,30) & location == "low" ~ "Relatively drier",
      chamber %in% c(10,20,30,40,50) & location == "high" ~ "Relatively drier",
      TRUE ~ "Relatively wetter"
    ),
    chamber_long = paste0(chamber, " (", type, ")"),
    chamber = as.factor(chamber)) %>%
    pivot_longer(matches("CH4_|CO2_"), 
                 names_to = c("gas", ".value"), 
                 names_sep="_" ) %>%
    filter(!gas == "Flag")
  
  updateDateInput(session, "today", 
                  max = as.Date(max(slopes_l0$TIMESTAMP)),
                  value = as.Date(max(slopes_l0$TIMESTAMP)))
  
  updateNumericInput(session, 'days_to_plot',
                     max = round(as.numeric(difftime(as.Date(max(slopes_l0$TIMESTAMP)), "2025-09-19", units = "days"))),
                     value = 3)
  
  output$plot_flux <- renderPlotly({
    slopes_recent <- slopes_l0 %>%
      filter(as.Date(TIMESTAMP) <= input$today,
             TIMESTAMP > (input$today - days(input$days_to_plot)))
    
    if(input$daily == "Daily mean"){
      slopes_recent2 <- slopes_recent %>%
        mutate(TIMESTAMP = as.POSIXct(as.Date(TIMESTAMP))) %>%
        group_by(TIMESTAMP, chamber, gas, location, type) %>%
        summarize(slope = mean(slope, na.rm = TRUE),
                  R2 = mean(R2, na.rm = TRUE),
                  .groups = "drop")
    } else slopes_recent2 <- slopes_recent
    
    p <- ggplot(slopes_recent2, aes(TIMESTAMP, slope, color = chamber, group = chamber, label = round(R2,2))) +
      geom_hline(yintercept = 0, color = "grey70") +
      geom_point(size = 0.5) + geom_line() +
      facet_grid(gas~location, scales = "free_y") +
      scale_x_datetime(date_labels = "%b %d") +
      scale_color_manual(values = color.gradient, name = "Chamber") +
      theme_dash
    
    ggplotly(p, tooltip=c("chamber","R2","TIMESTAMP"))
  })
  
  ###################################
  ### Partitioned CO2
  slopes_part <- read_csv("https://raw.githubusercontent.com/abbylewis/Chapada_flux_data/refs/heads/master/processed_data/partitioned_co2.csv", show_col_types = F) %>%
    filter(!is.na(location)) %>%
    mutate(DateTime = force_tz(DateTime, tzone = "Etc/GMT-3")) %>% 
    rename(chamber = Fluxing_Chamber) %>%
    mutate(type = case_when(
      chamber == 90~"Termites", 
      chamber %in% c(10,20,30) & location == "low" ~ "Relatively drier",
      chamber %in% c(10,20,30,40,50) & location == "high" ~ "Relatively drier",
      TRUE ~ "Relatively wetter"
    ),
    chamber_long = paste0(chamber, " (", type, ")"),
    chamber = as.factor(chamber),
    GPP = ifelse(!is_day, 0, GPP))
  
  output$plot_part <- renderPlotly({
    df <- slopes_part %>%
      filter(as.Date(DateTime) <= input$today,
             DateTime > (input$today - days(input$days_to_plot))) %>%
      select(NEE, GPP, Reco, DateTime, chamber, location, type) %>%
      pivot_longer(c(NEE, GPP, Reco), names_to = "gas") %>%
      mutate(value = ifelse(gas == "GPP", -value, value))
    
    if(input$daily == "Daily mean"){
      df <- df %>%
        mutate(DateTime = as.POSIXct(as.Date(DateTime))) %>%
        group_by(DateTime, chamber, gas, location, type) %>%
        summarize(value = mean(value, na.rm = TRUE), .groups = "drop")
    }
    
    p <- ggplot(df, aes(DateTime, value, color = chamber, group = chamber)) +
      geom_hline(yintercept = 0, color = "grey70") +
      geom_point(size = 0.5) + geom_line() +
      facet_grid(gas~location, scales = "free_y") +
      scale_x_datetime(date_labels = "%b %d") +
      scale_color_manual(values = color.gradient, name = "Chamber") +
      theme_dash
    
    ggplotly(p)
  })
  
  ###################################
  ### Met
  met <- read_csv("https://raw.githubusercontent.com/abbylewis/Chapada_flux_data/refs/heads/master/processed_data/met_2025_dashboard.csv", show_col_types = F) %>%
    mutate(TIMESTAMP = force_tz(TIMESTAMP, tzone = "Etc/GMT-3"))
  
  output$plot_met <- renderPlotly({
    df <- met %>%
      filter(as.Date(TIMESTAMP) <= input$today,
             TIMESTAMP > (input$today - days(input$days_to_plot))) %>%
      select(SlrFD_W_Avg, AirT_C_Avg, Rain_mm_Tot, TIMESTAMP) %>%
      pivot_longer(c(SlrFD_W_Avg, AirT_C_Avg, Rain_mm_Tot), names_to = "metric")
    
    if(input$daily == "Daily mean"){
      df <- df %>%
        mutate(TIMESTAMP = as.POSIXct(as.Date(TIMESTAMP))) %>%
        group_by(TIMESTAMP, metric) %>%
        summarize(value = mean(value, na.rm = TRUE), .groups = "drop")
    }
    
    p <- ggplot(df, aes(TIMESTAMP, value)) +
      geom_hline(yintercept = 0, color = "grey70") +
      geom_point(size = 0.5) + geom_line() +
      facet_wrap(~metric, scales = "free_y", ncol = 1) +
      scale_x_datetime(date_labels = "%b %d") +
      theme_dash
    
    ggplotly(p)
  })
  
  ###################################
  ### Redox
  redox <- read_csv("https://raw.githubusercontent.com/abbylewis/Chapada_flux_data/refs/heads/master/processed_data/redox_2025_dashboard.csv")
  
  output$plot_redox <- renderPlotly({
    df <- redox %>%
      filter(as.Date(TIMESTAMP) <= input$today,
             TIMESTAMP > (input$today - days(input$days_to_plot))) %>%
      mutate(chamber = chamber*10,
             type = case_when(
               chamber == 90~"Termites", 
               chamber %in% c(10,20,30) & location == "low" ~ "Relatively drier",
               chamber %in% c(10,20,30,40,50) & location == "high" ~ "Relatively drier",
               TRUE ~ "Relatively wetter"
             ),
             chamber = as.factor(chamber),
             depth = paste0(depth, "cm"))
    
    if(input$daily == "Daily mean"){
      df <- df %>%
        mutate(TIMESTAMP = as.POSIXct(as.Date(TIMESTAMP))) %>%
        group_by(TIMESTAMP, location, chamber, depth, ref, type) %>%
        summarize(value = mean(value, na.rm = TRUE), .groups = "drop")
    }
    
    p <- ggplot(df, aes(TIMESTAMP, value, color = chamber)) +
      geom_hline(yintercept = 0, color = "grey70") +
      geom_point(size = 0.5) +
      geom_line(aes(group = paste0(chamber, ref, depth))) +
      facet_grid(depth~location) +
      scale_x_datetime(date_labels = "%b %d") +
      scale_color_manual(values = color.gradient, name = "Chamber") +
      theme_dash
    
    ggplotly(p)
  })
  
  ###################################
  ### Teros
  teros <- read_csv("https://raw.githubusercontent.com/abbylewis/Chapada_flux_data/refs/heads/master/processed_data/teros_2025_dashboard.csv")
  
  output$plot_teros <- renderPlotly({
    df <- teros %>%
      filter(as.Date(TIMESTAMP) <= input$today,
             TIMESTAMP > (input$today - days(input$days_to_plot))) %>%
      mutate(chamber = chamber*10,
             type = case_when(
               chamber == 90~"Termites", 
               chamber %in% c(10,20,30) & location == "low" ~ "Relatively drier",
               chamber %in% c(10,20,30,40,50) & location == "high" ~ "Relatively drier",
               TRUE ~ "Relatively wetter"
             ),
             chamber = as.factor(chamber))
    
    if(input$daily == "Daily mean"){
      df <- df %>%
        mutate(TIMESTAMP = as.POSIXct(as.Date(TIMESTAMP))) %>%
        group_by(TIMESTAMP, location, chamber, type, var) %>%
        summarize(value = mean(value, na.rm = TRUE), .groups = "drop")
    }
    
    p <- ggplot(df, aes(TIMESTAMP, value, color = chamber)) +
      geom_point(size = 0.5) +
      geom_line(aes(group = paste0(chamber, var))) +
      facet_grid(var~location, scales = "free_y") +
      scale_x_datetime(date_labels = "%b %d") +
      scale_color_manual(values = color.gradient, name = "Chamber") +
      theme_dash
    
    ggplotly(p)
  })
  
  ###################################
  ### BME
  bme <- read_csv("https://raw.githubusercontent.com/abbylewis/Chapada_flux_data/refs/heads/master/processed_data/bme_2025_dashboard.csv")
  
  output$plot_bme <- renderPlotly({
    df <- bme %>%
      filter(as.Date(TIMESTAMP) <= input$today,
             TIMESTAMP > (input$today - days(input$days_to_plot))) %>%
      mutate(chamber = chamber*10,
             type = case_when(
               chamber == 90~"Termites", 
               chamber %in% c(10,20,30) & location == "low" ~ "Relatively drier",
               chamber %in% c(10,20,30,40,50) & location == "high" ~ "Relatively drier",
               TRUE ~ "Relatively wetter"
             ),
             chamber = as.factor(chamber))
    
    if(input$daily == "Daily mean"){
      df <- df %>%
        mutate(TIMESTAMP = as.POSIXct(as.Date(TIMESTAMP))) %>%
        group_by(TIMESTAMP, location, chamber, type, research_name) %>%
        summarize(value = mean(value, na.rm = TRUE), .groups = "drop")
    }
    
    p <- ggplot(df, aes(TIMESTAMP, value, color = chamber)) +
      geom_point(size = 0.5) +
      geom_line(aes(group = paste0(chamber, research_name))) +
      facet_grid(research_name~location, scales = "free_y") +
      scale_x_datetime(date_labels = "%b %d") +
      scale_color_manual(values = color.gradient, name = "Chamber") +
      theme_dash
    
    ggplotly(p)
  })
}

shinyApp(ui, server)
