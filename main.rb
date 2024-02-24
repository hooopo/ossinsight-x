require 'bundler/setup'

require 'dotenv/load'
require 'pry'
require 'oauth'

require_relative 'create_tweet'

client = CreateTweet.new(
	consumer_key: ENV['CONSUMER_KEY'],
	consumer_secret: ENV['CONSUMER_SECRET'],
	access_token: ENV['ACCESS_TOKEN'],
	access_token_secret: ENV['ACCESS_TOKEN_SECRET']
)

# client.get_access_token_from_user

resp = client.create("Hello!")

if resp.success?
	puts "Tweet created!"
else
	puts "Error: #{resp.code}"
end

