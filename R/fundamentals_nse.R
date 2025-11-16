# =============================================================
# Get NSE Fundamentals (Core Function for Your Package)
# =============================================================

#' Get fundamentals for a stock symbol from NSE India
#'
#' This function retrieves market, valuation, and company fundamentals
#' for a given NSE stock symbol using the NSE India public API. It returns
#' a tibble with details including last traded price, change percentages,
#' 52-week high/low, market cap, valuation ratios, and more.
#'
#' Internally, the function manages NSE session cookies, performs the
#' authenticated GET request, and extracts relevant fields safely.
#'
#'
#' @return A tibble containing fundamentals data for the specified symbol.
#'
#' @examples
#' \dontrun{
#'   get_nse_fundamentals("TCS")
#' }
#'
#' @import httr
#' @import jsonlite
#' @importFrom tibble tibble
#' @importFrom dplyr mutate across
#' @importFrom magrittr %>%
#' @importFrom stats setNames
#' @importFrom dplyr where
#' @importFrom dplyr mutate across where na_if
#' @export
# =============================================================


# -------------------------------------------------------------
# Helper: Get fresh NSE cookies
# -------------------------------------------------------------
nse_get_cookies <- function() {
  url <- "https://www.nseindia.com"

  resp <- httr::GET(
    url,
    httr::add_headers(
      `User-Agent` = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)",
      `Accept-Language` = "en-US,en;q=0.9"
    )
  )

  cookies <- httr::cookies(resp)

  if (nrow(cookies) == 0) {
    stop("\u274C Failed to fetch NSE cookies.")
  }

  cookies
}


# -------------------------------------------------------------
# Helper: Make authenticated GET request
# -------------------------------------------------------------
nse_get_json <- function(url, cookies) {
  resp <- httr::GET(
    url,
    httr::add_headers(
      `User-Agent`       = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)",
      `Accept-Language`  = "en-US,en;q=0.9",
      `Referer`          = "https://www.nseindia.com/"
    ),
    httr::set_cookies(.cookies = stats::setNames(cookies$value, cookies$name))
  )

  if (resp$status_code != 200) {
    stop(paste0("\u274C NSE API returned status: ", resp$status_code))
  }

  jsonlite::fromJSON(
    httr::content(resp, as = "text", encoding = "UTF-8")
  )
}


# -------------------------------------------------------------
# Main Function: Get Fundamentals for an NSE Symbol
# -------------------------------------------------------------
get_nse_fundamentals <- function(symbol) {

  symbol <- toupper(symbol)

  # Step 1 — get cookies
  cookies <- nse_get_cookies()

  # Step 2 — fetch quote data
  base_url <- "https://www.nseindia.com/api/quote-equity?symbol="
  data <- nse_get_json(paste0(base_url, symbol), cookies)

  # Step 3 — validate data
  if (is.null(data$priceInfo$lastPrice)) {
    stop("\u274C No data found for symbol: ", symbol)
  }

  # Step 4 — safe extractor
  safe_extract <- function(x) {
    if (is.null(x) || length(x) == 0) return(NA)
    x
  }

  # Step 5 — create fundamentals tibble
  fundamentals <- tibble::tibble(
    symbol        = symbol,
    companyName   = safe_extract(data$info$companyName),
    industry      = safe_extract(data$industryInfo$sector),

    lastPrice     = safe_extract(data$priceInfo$lastPrice),
    change        = safe_extract(data$priceInfo$change),
    pChange       = safe_extract(data$priceInfo$pChange),

    dayHigh       = safe_extract(data$priceInfo$intraDayHighLow$max),
    dayLow        = safe_extract(data$priceInfo$intraDayHighLow$min),

    week52High    = safe_extract(data$priceInfo$weekHighLow$max),
    week52Low     = safe_extract(data$priceInfo$weekHighLow$min),

    marketCap     = safe_extract(data$securityInfo$marketCap),
    faceValue     = safe_extract(data$securityInfo$faceValue),
    industryPE    = safe_extract(data$metadata$industryPE),
    pe            = safe_extract(data$metadata$pdSymbolPe),
    eps           = safe_extract(data$metadata$pdSymbolEps),

    bookValue     = safe_extract(data$metadata$bookValue),
    beta          = safe_extract(data$metadata$beta),
    dividendYield = safe_extract(data$metadata$dividendYield)
  )

  # Step 6 — clean mixed and list fields
  fundamentals <- fundamentals %>%
    dplyr::mutate(across(where(is.list), ~ ifelse(lengths(.) == 0, NA, unlist(.)))) %>%
    dplyr::mutate(across(where(is.logical), ~ as.numeric(.))) %>%
    dplyr::mutate(across(where(is.character), ~ dplyr::na_if(.x, "")))

  fundamentals
}
