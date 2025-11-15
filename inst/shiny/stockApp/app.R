library(shiny)
library(bslib)

# Load package functions if needed
# library(stockappraghav)

# ----------------------------------------------------------
# 1. Source all modules (kept inside inst/shiny/stockApp/modules)
# ----------------------------------------------------------
modules_path <- "modules"

source(file.path(modules_path, "dashboard_module.R"))
source(file.path(modules_path, "stock_explorer_module.R"))
source(file.path(modules_path, "fundamentals_module.R"))
source(file.path(modules_path, "screener_module.R"))
source(file.path(modules_path, "portfolio_module.R"))
source(file.path(modules_path, "buffett_module.R"))
source(file.path(modules_path, "settings_module.R"))

# ----------------------------------------------------------
# 2. UI
# ----------------------------------------------------------
ui <- navbarPage(
  title = "StockAppRaghav",
  theme = bs_theme(version = 5, bootswatch = "flatly"),

  tabPanel("Dashboard", dashboard_ui("dashboard")),
  tabPanel("Stock Explorer", stock_explorer_ui("stockexplorer")),
  tabPanel("Fundamentals", fundamentals_ui("fundamentals")),
  tabPanel("Screener", screener_ui("screener")),
  tabPanel("Buffett Analysis", buffett_ui("buffett")),
  tabPanel("Portfolio", portfolio_ui("portfolio")),
  tabPanel("Settings", settings_ui("settings"))
)

# ----------------------------------------------------------
# 3. Server
# ----------------------------------------------------------
server <- function(input, output, session) {
  dashboard_server("dashboard")
  stock_explorer_server("stockexplorer")
  fundamentals_server("fundamentals")
  screener_server("screener")
  buffett_server("buffett")
  portfolio_server("portfolio")
  settings_server("settings")
}

# ----------------------------------------------------------
# 4. App Run
# ----------------------------------------------------------
shinyApp(ui, server)
