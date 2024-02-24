require 'uri'
require 'open-uri'
require 'json'

class TrendingRepo
  attr_reader :lang, :period, :url

  def initialize(lang:, period: "past_week", limit: 5)
    @lang = lang
    @period = period
    if lang.empty?
      @url = "https://api.ossinsight.io/v1/trends/repos/?period=#{period}"
    else
      @url = "https://api.ossinsight.io/v1/trends/repos/?period=#{period}&language=#{lang}"
    end
  end

  def repos
    body = URI.open(url).read
    parsed_body = JSON.parse(body)
    parsed_body.dig("data", "rows")[0,5]
  end
end