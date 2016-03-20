require 'net/https'
require 'open-uri'
require 'json'
require 'socket'
require 'bigdecimal'
require 'yaml'

def get_user_info(nick)
  user = YAML.load_file('./address.yml')[nick]
  return say("No address info for #{nick}") if !user

  address = user['addr']
  investment = user['investment']
  url  = "http://api.etherscan.io/api?module=account&action=balance&address=#{address}&tag=latest"
  json = JSON.parse(open(url).read)
  balance = json['result'].slice(0, 3)

  user_data = {
    :balance => balance,
    :investment =>  investment
  }
end

def get_price_info
  url     = 'https://poloniex.com/public?command=returnTicker'
  json    = JSON.parse(open(url).read)

  btc        = json['BTC_ETH']['last'].slice(0, 7)
  btc_usd    = json['USDT_BTC']['last'].slice(0, 7)
  eth_volume = json['BTC_ETH']['baseVolume'].to_f
  eth_usd    = BigDecimal(btc) * BigDecimal(btc_usd)

  results = {
    :btc => btc,
    :eth_usd => eth_usd,
    :volume => eth_volume,
  }
end

def say(msg)
  @socket.puts("PRIVMSG #{@chan} :#{msg}\n")
end

def run(verbose = false, test_mode = false)
  nick = 'etherb0t'
  @chan = (test_mode ? '#etherbottest' : '#lifting')
  server = 'irc.rizon.net'
  port = 6667

  @socket = TCPSocket.open(server, port)

  @socket.puts "USER #{nick} 0 * #{nick}\n"
  @socket.puts "NICK #{nick}\n"

  sleep(1)

  @socket.puts "JOIN #{@chan}\n"

  @count = 0

  until @socket.eof? do
    msg = @socket.gets
    puts msg if verbose

    if msg.include?('PING')
      @socket.puts "PONG :pingis\n"
    elsif msg.include?('!eth')
      prices = get_price_info
      usd    = prices[:eth_usd].to_f.round(2)
      volume = prices[:volume].round(2)
      btc    = prices[:btc]

      say("BTC: #{btc} | USD: $#{usd} | Volume: #{volume}")
    elsif msg.include?('!myeth')
      parts      = msg.split
      nick       = parts[0].match(/^:(.*)\!~/)[1]
      user_data  = get_user_info(nick)
      next if !user_data

      balance    = user_data[:balance]
      investment = user_data[:investment]
      prices     = get_price_info
      earnings   = (balance.to_f * prices[:eth_usd].to_f).round
      returns    = ((earnings / investment.to_f) * 100).round

      say("Balance: #{balance} | Worth: $#{earnings} USD | Return: %#{returns}")
    end
  end

end

verbose = ARGV[0] || false
test_mode = ARGV[1] || false
run(verbose, test_mode)
