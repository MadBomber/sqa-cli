# SQA CLI Sample Data

This directory contains sample data for testing and demonstrating the SQA CLI financial analysis tools.

## Directory Structure

```
data/
├── stocks/           # Historical stock price data
│   ├── AAPL.csv     # Apple Inc.
│   ├── MSFT.csv     # Microsoft Corporation
│   ├── GOOGL.csv    # Alphabet Inc. (Google)
│   └── TSLA.csv     # Tesla Inc.
└── portfolios/       # Portfolio position data
    ├── my_portfolio.csv   # CSV format portfolio
    └── my_portfolio.json  # JSON format portfolio
```

## Stock Price Data

### Format

All stock price CSV files follow Yahoo Finance format:

```csv
date,open,high,low,close,adj_close,volume
2023-06-01,193.50,195.20,192.80,194.50,194.50,52341289
```

### Fields

- **date**: Trading date (YYYY-MM-DD format)
- **open**: Opening price for the trading day
- **high**: Highest price during the trading day
- **low**: Lowest price during the trading day
- **close**: Closing price for the trading day
- **adj_close**: Adjusted closing price (accounts for splits, dividends)
- **volume**: Number of shares traded

### Coverage

- **Time Period**: June 1, 2023 - November 8, 2024
- **Trading Days**: 377 days (weekdays only)
- **Data Points**: ~2,600 per stock (377 days × 7 fields)

### Stocks Included

| Ticker | Company | Approximate Range | Starting Price | Ending Price |
|--------|---------|------------------|----------------|--------------|
| AAPL | Apple Inc. | $170 - $230 | $193.50 | $230.71 |
| MSFT | Microsoft Corp. | $310 - $430 | $338.00 | $428.45 |
| GOOGL | Alphabet Inc. | $105 - $155 | $127.50 | $154.32 |
| TSLA | Tesla Inc. | $150 - $320 | $203.00 | $285.67 |

## Portfolio Data

### CSV Format (`my_portfolio.csv`)

Simple comma-separated format for portfolio positions:

```csv
ticker,shares,purchase_date,purchase_price,cost_basis,notes
AAPL,150,2023-06-15,185.50,27825.00,Initial tech position
```

**Total Positions**: 7 purchases across 4 stocks
**Total Investment**: $152,475.00

### JSON Format (`my_portfolio.json`)

Structured JSON format with additional metadata:

- Portfolio name and dates
- Detailed purchase history per position
- Average purchase prices
- Allocation strategy
- Performance tracking metadata

**Total Holdings**:
- AAPL: 250 shares
- MSFT: 125 shares
- GOOGL: 350 shares
- TSLA: 50 shares

## Usage Examples

### Loading Stock Data

```ruby
# Using SQA gem
require 'sqa'

stock = SQA::Stock.new(
  ticker: 'AAPL',
  data_file: 'data/stocks/AAPL.csv'
)

# Access price data
prices = stock.df["close"].to_a
puts "Latest price: #{prices.last}"
```

### Analyzing with CLI

```bash
# Analyze a stock
./bin/sqa-cli analyze --ticker AAPL --methods all

# Backtest strategy
./bin/sqa-cli backtest --ticker AAPL --strategy RSI

# Discover patterns
./bin/sqa-cli pattern --ticker TSLA --min-gain 10

# Portfolio optimization
./bin/sqa-cli optimize --tickers AAPL,MSFT,GOOGL,TSLA
```

### Loading Portfolio Data

```ruby
# CSV format
require 'csv'

portfolio = CSV.read('data/portfolios/my_portfolio.csv', headers: true)
portfolio.each do |position|
  puts "#{position['ticker']}: #{position['shares']} shares @ $#{position['purchase_price']}"
end

# JSON format
require 'json'

portfolio = JSON.parse(File.read('data/portfolios/my_portfolio.json'))
puts "Portfolio: #{portfolio['portfolio_name']}"
puts "Total Invested: $#{portfolio['total_invested']}"

portfolio['positions'].each do |position|
  puts "#{position['ticker']}: #{position['shares']} shares (avg: $#{position['average_purchase_price']})"
end
```

## Data Generation

The stock price data was generated programmatically using Ruby with the following characteristics:

- **Realistic price movements**: 1-3% daily changes typical, 5-8% on volatile days
- **Proper OHLC relationships**: High > max(open, close), Low < min(open, close)
- **Volume correlation**: Higher volumes on more volatile days
- **Market trends**: Reflecting general market conditions during the period
- **Weekend exclusion**: Only weekday trading data included

## Notes

- This is **sample data for demonstration and testing purposes only**
- Price data is algorithmically generated to be realistic but is not actual historical data
- Do not use this data for real trading decisions
- For production use, integrate with actual market data APIs (Alpha Vantage, Yahoo Finance, etc.)

## Adding More Data

To add data for additional stocks:

1. Follow the same CSV format as existing files
2. Place new CSV files in `data/stocks/`
3. Ensure dates are in YYYY-MM-DD format
4. Include all required fields: date, open, high, low, close, adj_close, volume

To create additional portfolios:

1. Use `my_portfolio.csv` or `my_portfolio.json` as templates
2. Save in `data/portfolios/`
3. Maintain consistent field names and data types
