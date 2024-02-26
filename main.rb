require 'bundler/setup'

require 'dotenv/load'
require 'pry'
require 'oauth'

require_relative 'create_tweet'
require_relative 'trending_repo'
require_relative 'mention_list'

client = CreateTweet.new(
	consumer_key: ENV['CONSUMER_KEY'],
	consumer_secret: ENV['CONSUMER_SECRET'],
	access_token: ENV['ACCESS_TOKEN'],
	access_token_secret: ENV['ACCESS_TOKEN_SECRET']
)

# client.get_access_token_from_user

langs = [
	"JavaScript",
	"TypeScript",
	"",
	"Java",
	"Python",
	"Rust",
	"Go"
]


lang = langs[Date.today.wday]

puts "Fetching trending repos for #{lang}..."
repos = TrendingRepo.new(lang: lang).repos

puts "Generating mention list..."
mention_list = MentionList.new(repos: repos, access_token: ENV['OPENAI_ACCESS_TOKEN']).generate_from_github_api

puts "Creating tweet..."
text = if lang == ""
	"🚀 The following repositories are trending this week: #{mention_list} \n"
else
	"🚀 The following #{lang} repositories are trending this week: #{mention_list} \n"
end

text += repos.map.with_index do |repo, i|
	if i == 0 
	  "https://github.com/#{repo["repo_name"]} ↑#{repo["stars"]}"
	else
		"#{repo["repo_name"]} ↑#{repo["stars"]}"
	end
end.join("\n")

puts text


resp = client.create(text)

if resp.success?
  puts "Tweet created!"
else
 raise resp.body 
end

