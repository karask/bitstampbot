require "bitstamp"

Bitstamp.setup do |config|
  config.key = 'ChyTLCqQQf7DO1or4viwb9CjeglKMXEw'
  config.secret = 'j2xxD6eMBC5pdaJfbyAaWmScnkkw960e'
  config.client_id = '76052'
end

tick = Bitstamp.ticker

puts tick.volume
puts tick.high
puts tick.low

if tick.high > tick.low 
  puts "Bid  " + tick.bid
  puts "Ask  " + tick.ask
end

# get all orders
orders = Bitstamp.orders.all
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

# create sell order
# Bitstamp.orders.sell(amount: 1.0, price: 111)
# create buy order
# Bitstamp.orders.buy(amount: 1.0, price: 111)


puts orders.size
