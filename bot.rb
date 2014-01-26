require "bitstamp"
require "logger"

#logfile = Time.now.strftime("%Y%m%d-%H%M%S") + ".log"
logfile = "log.log"
$LOG = Logger.new(logfile);

Bitstamp.setup do |config|
  config.key = ENV['BITSTAMP_KEY'] 
  config.secret = ENV['BITSTAMP_SECRET'] 
  config.client_id = ENV['BITSTAMP_CLIENT_ID'] 
end

buy_max_price = 326.0
buy_max_amount = 0.01
profitPercentage = 0.25

# check if last price is below buy_max_price every 60 secs
begin
  begin
    sleep(60)
    tick = Bitstamp.ticker
    puts "tick #{tick.last}"
  end until tick.last.to_f <= buy_max_price
rescue StandardError => se
  # propably a network error occurred
  $LOG.info "Exception raised: #{se}"
  $LOG.info "Didn't place buy order of #{buy_max_amount} BTC at #{tick.last} dollars"
  abort
end


# buy buy_max bitcoins (assumes you have the cash for now)
$LOG.info "Place Order: Buy #{buy_max_amount} at #{tick.last}"
Bitstamp.orders.buy(amount: buy_max_amount, price: tick.last)

# price to sell is 0.5% buy + 0.5% sell commission plus profitInDollars
# note: we calculate commission at the higher sell price so it is
#       slightly less commission
sellPrice = tick.last.to_f * (1.01+profitPercentage/100)
$LOG.info "Will try to sell at #{sellPrice} for a #{(1.01+profitPercentage/100)}% percentage profit"

# check if last price is above calculated sellPrice every 60 secs
begin
  begin
    sleep(60)
    tick = Bitstamp.ticker
    puts "tick #{tick.last}"
  end until tick.last.to_f >= sellPrice
rescue StandardError => se
  # propably a network error occurred
  $LOG.info "Exception raised: #{se}"
  $LOG.info "Didn't place sell order of #{buy_max_amount} BTC at #{sellPrice} dollars"
  abort
end

# sell buy_max bitcoins at sellPrice
$LOG.info "Place Order: Sell #{buy_max_amount} at #{sellPrice}"
Bitstamp.orders.sell(amount: buy_max_price, price: sellPrice)






#puts tick.volume
#puts tick.high
#puts tick.low

#if tick.high > tick.low 
#  puts "Bid  " + tick.bid
#  puts "Ask  " + tick.ask
#end

#order = Bitstamp.orders.sell(amount: 0.01, price: 1111)

# get all orders
#orders = Bitstamp.orders.all
#puts orders.size

# get all transactions
#transx = Bitstamp.user_transactions.all
#
#orders.each do |o|
#  puts o.id , o.datetime , o.type , o.price , o.amount
#end
#
#transx.each do |t|
#  puts t.datetime , t.id , t.type , t.usd , t.btc , t.fee , t.order_id
#end
