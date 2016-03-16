require 'net/https'
require 'open-uri'
require 'json'
require 'socket'
require 'bigdecimal'

def get_price
  response = JSON.parse(open('https://poloniex.com/public?command=returnTicker').read)
  account = JSON.parse(open('http://api.etherscan.io/api?module=account&action=balance&address=0x7b30b6675e44c31c51bb4771f983f2671121e745&tag=latest').read)
  btc = response['BTC_ETH']['last'].slice(0,7)
  btc_usd = response['USDT_BTC']['last'].slice(0,7)
  usd = BigDecimal(btc) * BigDecimal(btc_usd)
  balance = account['result'].slice(0,3)
  earnings = BigDecimal(usd) * BigDecimal(balance)
  returns = (earnings.to_f / 1480.to_f) * 100
  volume = response['BTC_ETH']['baseVolume']
  return "[BTC] #{btc} | [USD] $#{usd.to_f.round(2)} | [Volume] #{volume.to_f.round(2)} |  BP's balance: #{balance} ETH - earnings: $#{earnings.to_i} - #{returns.round}% return"
end

def run()
  nick = 'etherb0t'
  chan = '#lifting'
  server = 'irc.rizon.net'
  port = 6667

  socket = TCPSocket.open(server, port)

  socket.puts "USER #{nick} 0 * #{nick}\n"
  socket.puts "NICK #{nick}\n"

  sleep(1)

  socket.puts "JOIN #{chan}\n"

  @count = 0

  until socket.eof? do
    msg = socket.gets
    puts msg

    if msg.include?('PING')
      socket.puts "PONG :pingis\n"
    elsif msg.include?('!eth')
      socket.puts "PRIVMSG #{chan} :#{get_price}\n"
    end
  end

end

run()
