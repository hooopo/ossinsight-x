require 'openai'
require 'open-uri'
require 'json'
require 'uri'

class MentionList
  attr_reader :repos, :client

  def initialize(repos:, access_token:)
    @repos = repos
    @client = OpenAI::Client.new(access_token: access_token)
  end

  def prompt
    <<~PROMPT
      The following repositories are trending:
      #{repos.map { |repo| repo.slice("repo_name", "contributor_logins") } }
      summary total 5 twitter mentions related to these repositories, only return metion list, for example:
      @hello @world
      only return 5 mentions, total response less than 80 characters
    PROMPT
  end

  def generate_from_github_api 
    github_logins = repos.map { |repo| repo["contributor_logins"].split(",") }.flatten.uniq
    twitter_logins = github_logins.map do |login|
      JSON.parse(URI.open("https://api.github.com/users/#{login}").read)["twitter_username"] rescue nil
    end.compact
    twitter_logins[0, 5].map { |login| "@#{login}" }.join(" ")
  end

  def generate
    response = client.chat(
      parameters: {
          model: "gpt-4", # Required.
          messages: [{ role: "user", content: prompt}],
          temperature: 1,
      })
    response.dig("choices", 0, "message", "content")
  end
end