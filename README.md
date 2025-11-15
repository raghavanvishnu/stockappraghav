README.md (Copy–Paste Ready)
# stockappraghav 📈  
**A Modular R Package + Shiny App for Indian Stock Market Analytics**

`stockappraghav` is a personal project by Vishnu S. Raghavan that integrates:

- Live NSE fundamentals  
- Yahoo Finance price data  
- Modular Shiny dashboards  
- Screeners  
- Buffett-style valuation  
- Portfolio analytics  

The app is built using a clean R package architecture, with the full Shiny application stored under `inst/shiny/stockApp/`.

---

## 🚀 Features (Work in Progress)

### ✔ NSE Fundamentals  
Fetch live market data directly from NSE India using the public JSON API:

- Last price  
- Day high/low  
- 52-week high/low  
- P/E, Industry P/E  
- EPS  
- Book value  
- Dividend yield  
- Beta  
- Market cap  

### ✔ Modular Shiny Architecture  
Each module has separate UI/server files:



inst/shiny/stockApp/modules/
├─ dashboard_module.R
├─ stock_explorer_module.R
├─ fundamentals_module.R
├─ screener_module.R
├─ portfolio_module.R
├─ buffett_module.R
└─ settings_module.R


### ✔ Stock Explorer (coming soon)  
- Candlestick chart  
- Volume bars  
- SMA / EMA  
- RSI / MACD  

### ✔ Screener (coming soon)  
Filter stocks by:

- PE  
- ROE  
- ROCE  
- Market cap  
- Zero-debt  

### ✔ Buffett Analysis (coming soon)  
- Intrinsic value  
- Discount rate  
- Margin of safety  

---

## 📦 Installation (development version)

```r
# install.packages("devtools")
devtools::install_github("raghavanvishnu/stockappraghav")

🧪 Example: Fetch NSE Fundamentals
library(stockappraghav)

get_nse_fundamentals("RELIANCE")
get_nse_fundamentals("ASIANPAINT")


Returns a tidy tibble:

# A tibble: 1 × 18
  symbol companyName industry lastPrice pe eps bookValue dividendYield …

🖥 Running the Shiny App

After installing the package:

library(stockappraghav)
shiny::runApp(system.file("shiny/stockApp", package = "stockappraghav"))


This loads the full multi-tab Shiny dashboard.

📁 Project Structure
stockappraghav/
  ├─ R/                      # Core R functions
  ├─ inst/shiny/stockApp/    # Full Shiny application
  │     ├─ app.R
  │     └─ modules/
  ├─ DESCRIPTION
  ├─ NAMESPACE
  ├─ tests/
  ├─ vignettes/
  └─ README.md

🛠 Development Workflow

Main branch:

Stable, production-ready code

Feature branches:

feature-fundamentals-ui

feature-stock-explorer

feature-screener

feature-buffett

feature-portfolio

🧑‍💻 Author

Vishnu S. Raghavan
R Developer | Data Scientist | Stock Market Enthusiast

📜 License

MIT License (to be added).

⚠ Disclaimer

This project is for personal and educational purposes only.
Not intended for financial advice or commercial use.
