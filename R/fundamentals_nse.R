# ============================================================
# GET NSE FUNDAMENTALS (Core Function for Your Package)
# ============================================================

library(httr)
library(jsonlite)
library(dplyr)
library(purrr)
library(stringr)

# ---------------------------------------------
# Helper: Get fresh NSE cookies
# ---------------------------------------------
nse_get_cookies <- function() {
  url <- "https://www.nseindia.com"
  resp <- httr::GET(url,
                    httr::add_headers(
                      `User-Agent` = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)",
                      `Accept-Language` = "en-US,en;q=0.9"
                    ))
  cookies <- httr::cookies(resp)
  if (nrow(cookies) == 0) stop("❌ Failed to fetch NSE cookies.")
  return(cookies)
}

# ---------------------------------------------
# Helper: Make authenticated GET request
# ---------------------------------------------
nse_get_json <- function(url, cookies) {
  resp <- httr::GET(
    url,
    httr::add_headers(
      `User-Agent` = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)",
      `Accept-Language` = "en-US,en;q=0.9",
      `Referer` = "https://www.nseindia.com/"
    ),
    httr::set_cookies(.cookies = setNames(cookies$value, cookies$name))
  )

  if (resp$status_code != 200) {
    stop(paste("❌ NSE API returned status:", resp$status_code))
  }

  jsonlite::fromJSON(httr::content(resp, as = "text", encoding = "UTF-8"))
}

# ---------------------------------------------
# MAIN FUNCTION: Get Fundamentals
# ---------------------------------------------
get_nse_fundamentals <- function(symbol) {
  symbol <- toupper(symbol)

  # Step 1: Get cookies
  cookies <- nse_get_cookies()

  # Step 2: Fetch main quote data
  base_url <- "https://www.nseindia.com/api/quote-equity?symbol="
  full_url <- paste0(base_url, symbol)

  data <- nse_get_json(full_url, cookies)

  # Quick check
  if (is.null(data$priceInfo$lastPrice)) {
    stop("❌ No data found for symbol: ", symbol)
  }

  # Step 3: Extract fields safely
 # safe_extract <- function(x) ifelse(is.null(x), NA, x)
  safe_extract <- function(x) {
    if (is.null(x) || length(x) == 0) return(NA)
    return(x)
  }
  fundamentals <- tibble(
    symbol           = symbol,
    companyName      = safe_extract(data$info$companyName),
    industry         = safe_extract(data$industryInfo$sector),
    lastPrice        = safe_extract(data$priceInfo$lastPrice),
    change           = safe_extract(data$priceInfo$change),
    pChange          = safe_extract(data$priceInfo$pChange),

    dayHigh          = safe_extract(data$priceInfo$intraDayHighLow$max),
    dayLow           = safe_extract(data$priceInfo$intraDayHighLow$min),

    week52High       = safe_extract(data$priceInfo$weekHighLow$max),
    week52Low        = safe_extract(data$priceInfo$weekHighLow$min),

    marketCap        = safe_extract(data$securityInfo$marketCap),
    faceValue        = safe_extract(data$securityInfo$faceValue),
    industryPE       = safe_extract(data$metadata$industryPE),
    pe               = safe_extract(data$metadata$pdSymbolPe),
    eps              = safe_extract(data$metadata$pdSymbolEps),

    bookValue        = safe_extract(data$metadata$bookValue),
    beta             = safe_extract(data$metadata$beta),
    dividendYield    = safe_extract(data$metadata$dividendYield)
  )
  fundamentals <- fundamentals %>%
    mutate(across(where(is.list), ~ ifelse(lengths(.) == 0, NA, unlist(.)))) %>%
    mutate(across(where(is.logical), ~ as.numeric(.))) %>%
    mutate(across(where(is.character), ~ na_if(.x, "")))
  return(fundamentals)
}
