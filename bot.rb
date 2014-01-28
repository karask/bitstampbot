require "bitstamp"
require "logger"

logfile = "logbot.log"
#logfile = Time.now.strftime("log-%Y%m%d-%H%M%S") + ".log"
File.delete(logfile)
$LOG = Logger.new(logfile);

Bitstamp.setup do |config|
  config.key = ENV['BITSTAMP_KEY'] 
  config.secret = ENV['BITSTAMP_SECRET'] 
  config.client_id = ENV['BITSTAMP_CLIENT_ID'] 
end

buy_max_price = 772.5
buy_max_amount = 0.05
profitPercentage = 0.55
commissionPercentage = 0.50
tickEverySecs = 5
retries = 10

# check if last price is below buy_max_price every 60 secs
attempt = 0
begin
  begin
    sleep(tickEverySecs)
    tick = Bitstamp.ticker
    puts "tick #{tick.last} -- will buy #{buy_max_amount} BTC at <= #{buy_max_price} dollars"
  end until tick.last.to_f <= buy_max_price
rescue StandardError => se
  # propably a network error occurred
  $LOG.info "Exception raised: #{se}"
  $LOG.info "Didn't place buy order of #{buy_max_amount} BTC at <= #{buy_max_price} dollars with attempt ##{attempt + 1}"
  attempt += 1
  sleep 0.1
  if attempt < retries 
    retry
  else
    raise se
  end
end


# buy buy_max bitcoins (assumes you have the cash for now)
Bitstamp.orders.buy(amount: buy_max_amount, price: tick.last)
$LOG.info "Placed Order: Buy #{buy_max_amount} at #{tick.last}"
puts "Placed Order: Buy #{buy_max_amount} at #{tick.last}"

# price to sell is commissionPercentage x2 (buy/sell) plus profitInDollars
# note: we calculate commission at the higher sell price so it is
#       slightly less commission (however, the commission is only base at
#       buy price!)
percentageMultiplier = 1 + commissionPercentage*2.0/100.0 + profitPercentage/100
sellPrice = tick.last.to_f * percentageMultiplier
$LOG.info "Will try to sell at #{sellPrice} for a #{percentageMultiplier - 1}% percentage profit"

# check if last price is above calculated sellPrice every 60 secs
attempt = 0
begin
  begin
    sleep(tickEverySecs)
    tick = Bitstamp.ticker
    puts "tick #{tick.last} -- will sell #{buy_max_amount} BTC for at least #{sellPrice} dollars"
  end until tick.last.to_f >= sellPrice
rescue StandardError => se
  # propably a network error occurred
  $LOG.info "Exception raised: #{se}"
  $LOG.info "Didn't place sell order of #{buy_max_amount} BTC at #{sellPrice} dollars with attempt ##{attempt+1}"
  attempt += 1
  sleep 0.1
  if attempt < retries
    retry
  else
    raise se
  end
end

# sell buy_max bitcoins at sellPrice
Bitstamp.orders.sell(amount: buy_max_amount, price: tick.last)
$LOG.info "Placed Order: Sell #{buy_max_amount} at #{tick.last}"
puts "Placed Order: Sell #{buy_max_amount} at #{tick.last}"






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
