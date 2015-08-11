import ystockquote

ticker = 'GOOG'
start = '20080101'
end = '20080523'

data = ystockquote.get_historical_prices(ticker, start, end)

closing_prices = [x[4] for x in data][1:]
closing_prices.reverse()

fh = open('data.txt', 'w')
for closing_price in closing_prices:
    fh.write(closing_price + '\n')
fh.close()

