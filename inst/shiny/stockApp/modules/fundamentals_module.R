fundamentals_ui <- function(id) {
  ns <- NS(id)

  tagList(
    # Load CSS + JS
    tags$head(
      tags$link(rel = "stylesheet",
                href = "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css"),
      tags$script(src = "https://cdnjs.cloudflare.com/ajax/libs/jquery-sparklines/2.1.2/jquery.sparkline.min.js"),

      # Sparkline JS handler
      tags$script(HTML("
        Shiny.addCustomMessageHandler('sparkline_draw', function(data) {
          $('#' + data.id).sparkline(data.values, {
            type: 'line',
            width: '100%',
            height: '60px',
            lineColor: '#2C3E50',
            fillColor: '#D6EAF8',
            spotColor: false,
            minSpotColor: false,
            maxSpotColor: false
          });
        });
      "))
    ),

    h2("📚 Fundamentals Explorer"),

    # INPUT ROW
    fluidRow(
      column(4,
             textInput(ns("symbol"), "Enter NSE Symbol:", placeholder = "e.g. RELIANCE, TCS")),
      column(2,
             actionButton(ns("go"), "Get Data", class = "btn-primary"))
    ),

    hr(),

    # Company Logo + Sparkline
    fluidRow(
      column(2,
             uiOutput(ns("company_logo"))
      ),
      column(10,
             tags$div(
               style = "margin-top:20px;",
               tags$h4("Price Trend (last 3 months)"),
               tags$span(id = ns("sparkline"))
             )
      )
    ),

    hr(),

    uiOutput(ns("cards_ui")),  # Gradient cards

    hr(),

    h4("Full Data"),
    tableOutput(ns("fund_table"))
  )
}



# ============================================================
# SERVER
# ============================================================

fundamentals_server <- function(id) {
  moduleServer(id, function(input, output, session) {

    # -------------------------------------------------------------
    # Load fundamentals from your NSE function
    # -------------------------------------------------------------
    fundamentals_data <- eventReactive(input$go, {
      req(input$symbol)
      tryCatch({
        get_nse_fundamentals(input$symbol)
      }, error = function(e) tibble(error = e$message))
    })

    output$fund_table <- renderTable({
      fundamentals_data()
    })

    # -------------------------------------------------------------
    # Company Logo lookup
    # -------------------------------------------------------------
    logo_lookup <- list(
      "RELIANCE" = "relianceindustries.com",
      "TCS" = "tcs.com",
      "INFY" = "infosys.com",
      "ITC" = "itcportal.com",
      "HDFCBANK" = "hdfcbank.com",
      "HDFC" = "hdfcbank.com",
      "SBIN" = "sbi.co.in",
      "ASIANPAINT" = "asianpaints.com",
      "ULTRACEMCO" = "ultratechcement.com"
    )

    output$company_logo <- renderUI({
      df <- fundamentals_data()
      if (is.null(df) || "error" %in% names(df)) return(NULL)

      symbol <- toupper(df$symbol[1])
      domain <- logo_lookup[[symbol]]

      if (is.null(domain))
        return(tags$h4(symbol))

      logo_url <- paste0("https://logo.clearbit.com/", domain)

      tags$img(src = logo_url, height="70px",
               style="border-radius:8px; box-shadow:0 3px 10px rgba(0,0,0,0.15);")
    })

    # -------------------------------------------------------------
    # SPARKLINE DATA (Yahoo)
    # -------------------------------------------------------------
    get_sparkline_prices <- function(symbol) {
      url <- paste0(
        "https://query1.finance.yahoo.com/v8/finance/chart/",
        symbol,
        ".NS?interval=1d&range=3mo"
      )

      raw <- jsonlite::fromJSON(url)
      closes <- raw$chart$result[[1]]$indicators$quote[[1]]$close
      closes <- closes[!is.na(closes)]
      return(closes)
    }

    # Send Sparkline Data (CORRECT Shiny message pipeline)
    observeEvent(input$go, {
      df <- fundamentals_data()
      if (is.null(df) || "error" %in% names(df)) return(NULL)

      closes <- get_sparkline_prices(input$symbol)

      session$sendCustomMessage(
        type = "sparkline_draw",
        message = list(
          id = session$ns("sparkline"),
          values = closes
        )
      )
    })


    # -------------------------------------------------------------
    # Gradient Cards
    # -------------------------------------------------------------
    output$cards_ui <- renderUI({
      df <- fundamentals_data()
      if (is.null(df) || "error" %in% names(df)) return(NULL)

      vals <- df[1, ]
      change_color <- ifelse(vals$pChange >= 0, "#2ecc71", "#e74c3c")

      card <- function(title, value, icon, color1, color2) {
        tags$div(
          style = paste0(
            "display:inline-block; padding:15px; margin:8px;
             border-radius:12px; width:210px;
             box-shadow:0 3px 10px rgba(0,0,0,0.1);
             background: linear-gradient(135deg,", color1,",", color2,");
             color:#2C3E50;"
          ),
          tags$div(
            style = "display:flex; align-items:center; margin-bottom:10px;",
            tags$i(class = paste("fa-solid", icon),
                   style = "font-size:22px; margin-right:10px;"),
            tags$h5(title, style="font-weight:600; margin:0;")
          ),
          tags$h4(value, style="font-weight:700; margin-top:5px;")
        )
      }

      tagList(
        fluidRow(
          card("Price", vals$lastPrice, "fa-indian-rupee-sign", "#E3F2FD", "#BBDEFB"),
          card("Change (%)", paste0(round(vals$pChange,2), "%"), "fa-arrow-trend-up",
               "#E8F5E9", change_color),
          card("52W High", vals$week52High, "fa-arrow-up", "#FFF8E1", "#FFE0B2"),
          card("52W Low", vals$week52Low, "fa-arrow-down", "#FFEBEE", "#FFCDD2"),
          card("PE", vals$pe, "fa-chart-line", "#EDE7F6", "#D1C4E9"),
          card("Industry PE", vals$industryPE, "fa-building", "#E0F7FA", "#B2EBF2"),
          card("EPS", vals$eps, "fa-coins", "#FFF3E0", "#FFE0B2"),
          card("Book Value", vals$bookValue, "fa-book", "#E8EAF6", "#C5CAE9"),
          card("Dividend Yield", vals$dividendYield, "fa-percent", "#E8F5E9", "#C8E6C9"),
          card("Beta", vals$beta, "fa-wave-square", "#FFEBEE", "#FFCDD2")
        )
      )
    })
  })
}
