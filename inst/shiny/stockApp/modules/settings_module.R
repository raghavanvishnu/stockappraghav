settings_ui <- function(id) {
  ns <- NS(id)
  tagList(
    h2("⚙️ Settings"),
    p("Theme, API keys, cache settings coming soon...")
  )
}

settings_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    # Settings logic goes here
  })
}
