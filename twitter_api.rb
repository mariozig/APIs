require 'yaml'
require 'json'
require 'oauth'
require 'addressable/uri'

class TwitterApp
  attr_reader :access_token
  CONSUMER_KEY = 'f0XN7Wm737c6xrmX6MAwg'
  CONSUMER_SECRET = 'zu7YV9xhm0KxaLm9yFT719YOOxbeYMMfc6QP39ZKrsg'
  CONSUMER = OAuth::Consumer.new(CONSUMER_KEY, CONSUMER_SECRET,
    site: 'http://twitter.com')

  def initialize
    if File.exist?('token.yaml')
      @access_token = load_token
    else
      @access_token = get_access_token
      save_token(access_token)
    end
  end

  def save_token(access_token)
    File.open('token.yaml', 'w') do |f|
      f.puts access_token.to_yaml
    end
  end

  def load_token
    YAML.load_file('token.yaml')
  end

  def get_access_token
    request_token = CONSUMER.get_request_token
    puts "Please go to #{request_token.authorize_url} to authorize."

    puts "Login, and enter your verification code:"
    code = gets.chomp

    access_token = request_token.get_access_token(oauth_verifier: code)
  end

  def post_status
    print "What are you doing? "
    tweet = gets.chomp

    post_params = {
      status: tweet
    }

    post_url = Addressable::URI.new(
      scheme: "https",
      host: "api.twitter.com",
      path: "1.1/statuses/update.json"
    ).to_s

    access_token.post(post_url, post_params)
  end

  def get_timeline
    timeline = access_token.get('https://api.twitter.com/1.1/statuses/home_timeline.json').body
    timeline = JSON.parse(timeline)
  end

  def get_user_status
  end

  def dm_user
  end
end



# Request token URL https://api.twitter.com/oauth/request_token
# Authorize URL https://api.twitter.com/oauth/authorize
# Access token URL  https://api.twitter.com/oauth/access_token

# Access token  611773-sOBkPDP9mpbv40lgXH5CwOKG3y8RUJZdiBMjY7ChUA
# Access token secret 7ka5JDXtPecAgGbghnLzRx5fPg5qGPJtbo8M5Fkqfg
# Access level  Read-only