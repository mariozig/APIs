require 'yaml'
require 'json'
require 'oauth'
require 'addressable/uri'
require 'time'

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

  def get_your_tweet_on
    puts "Welcome to the Terminal Twitter Client!"
    while true
      puts
      puts "TWITTER IN THE TERMINAL"
      puts "1. Post a tweet"
      puts "2. View your timeline"
      puts "3. DM another user"
      puts "4. See someone's status"
      print ">> "

      case gets.chomp.to_i
      when 1 then post_status
      when 2 then print_timeline
      when 3 then dm_user
      when 4 then see_user_status
      else
        exit
      end
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

    post = access_token.post(post_url, post_params)
    check_success(post)
  end

  def print_timeline
    timeline = JSON.parse(get_timeline)
    print_statuses(timeline)
  end

  def get_timeline
    access_token.get('https://api.twitter.com/1.1/statuses/home_timeline.json').body
  end

  def print_statuses(statuses)
    statuses.each do |post|
      text = post['text']
      user = post['user']['screen_name']
      time = Time.parse(post['created_at']).strftime("%a %l:%M%P")
      puts "#{time} | #{user}: #{text}"
    end
  end

  def see_user_status
    print "Who's status do you want to see? "
    screen_name = gets.chomp.downcase
    statuses = JSON.parse(get_user_status(screen_name)).take(5)
    print_statuses(statuses)
  end

  def get_user_status(screen_name)
    params = {
      screen_name: screen_name
    }

    url = Addressable::URI.new(
      scheme: "https",
      host: "api.twitter.com",
      path: "1.1/statuses/user_timeline.json",
      query_values: params
    ).to_s

    access_token.get(url).body
  end

  def dm_user
    print "Who do you want to message? "
    screen_name = gets.chomp.downcase
    print "What do you want to say? "
    dm = gets.chomp

    post_params = {
      screen_name: screen_name,
      text: dm
    }

    post_url = Addressable::URI.new(
      scheme: "https",
      host: "api.twitter.com",
      path: "1.1/direct_messages/new.json"
    ).to_s

    check_success(access_token.post(post_url, post_params))
  end

  def check_success(http_header)
    if http_header.code == "200"
      puts "Success!"
    else
      puts "Sorry, something went wrong."
    end
  end

  def get_screen_name
    print "Screen name: "
    gets.chomp.downcase
  end
end

TwitterApp.new.get_your_tweet_on

# Request token URL https://api.twitter.com/oauth/request_token
# Authorize URL https://api.twitter.com/oauth/authorize
# Access token URL  https://api.twitter.com/oauth/access_token

# Access token  611773-sOBkPDP9mpbv40lgXH5CwOKG3y8RUJZdiBMjY7ChUA
# Access token secret 7ka5JDXtPecAgGbghnLzRx5fPg5qGPJtbo8M5Fkqfg
# Access level  Read-only