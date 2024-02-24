require 'oauth'
require 'json'
require 'typhoeus'
require 'oauth/request_proxy/typhoeus_request'

class CreateTweet
  attr_reader :consumer_key, :consumer_secret, :access_token, :access_token_secret

  attr_reader :url

  def initialize(consumer_key:, consumer_secret:, access_token:, access_token_secret:)
    @consumer_key = consumer_key
    @consumer_secret = consumer_secret
    @access_token = access_token
    @access_token_secret = access_token_secret
    @url = "https://api.twitter.com/2/tweets"
  end

  def create(text)
    json_payload = {"text": text}
    options = {
        :method => :post,
        headers: {
           "User-Agent": "v2CreateTweetRuby",
          "content-type": "application/json"
        },
        body: JSON.dump(json_payload)
    }
    request = Typhoeus::Request.new(url, options)

    oauth_params = {
      consumer: consumer, 
      token: OAuth::AccessToken.new(consumer, access_token, access_token_secret)
    }
    oauth_helper = OAuth::Client::Helper.new(request, oauth_params.merge(:request_uri => url))
    request.options[:headers].merge!({"Authorization" => oauth_helper.header})
    response = request.run
    return response
  end

  def consumer
    @consumer ||= OAuth::Consumer.new(consumer_key, consumer_secret,
                        :site => 'https://api.twitter.com',
                        :authorize_path => '/oauth/authenticate',
                        :debug_output => false)
  end

  
  # This method is used to obtain an access token from a user
  def get_access_token_from_user
    request_token = consumer.get_request_token()
    puts "Follow this URL to have a user authorize your app: #{request_token.authorize_url()}"
    puts "Enter PIN: "
    pin = gets.strip
    token = request_token.token
    token_secret = request_token.secret
    hash = { :oauth_token => token, :oauth_token_secret => token_secret }
    request_token  = OAuth::RequestToken.from_hash(consumer, hash)
    access_token_obj = request_token.get_access_token({:oauth_verifier => pin})
    puts({
      access_token: access_token_obj.token,
      access_token_secret: access_token_obj.secret
    })
  end
end