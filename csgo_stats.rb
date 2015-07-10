$LOAD_PATH << '.'
require 'rubygems'
require 'net/http'
require 'open-uri'
require 'json'
require 'nokogiri'
require 'cgi'
require 'digest'
require 'action_view'
require 'json_fetcher'
include ActionView::Helpers::DateHelper

class CsgoStats
  include JsonFetcher
  FAILURE_TO_RETREIVE = "Failed to GET CSGO data from csgo-stats.com"
  ENDPOINT = "http://csgo-stats.com/destinygg/?ajax&uptodate"
  HUMAN_LINK = "http://csgo-stats.com/destinygg/"
  VALID_WORDS = %w{cs csgo counterstrike ayyylmao sotriggered}
  RATE_LIMIT = 16 # seconds

  attr_accessor :regex, :last_message
  def initialize
    @regex = /^!(#{VALID_WORDS.join('|')})/i
  end
  
  def ready
    last_time = @last_time || 0
    now = Time.now.to_i
    if now - last_time > RATE_LIMIT
      @last_time = now
      return true
    end
    return false
  end
  
  def check(query)
    return trycheck(query)
  rescue Exception => e
    m = e.message
    m << "\n\n --->"
    m << e.backtrace.join("\n|\n")
    puts m
    " AYYYLMAO tell hephaestus something broke. Exception: #{e.message.to_s}"
  end
  
  def trycheck(query)
    jsn = fetchjson(ENDPOINT, FAILURE_TO_RETREIVE)
    parsed_html = Nokogiri.parse(jsn["content"])
    lastmatch = parsed_html.css("#lastmatch")
    lmtxt = lastmatch.children[3].text()
    result = lmtxt.include?('Win') ? 'won' : 'lost'
    if lmtxt.include?('.')
      lmtxt = lmtxt.split('.')[0]
    end
    lmparts = lmtxt.split('/')
    wins = lmparts[0].to_i
    losses = lmparts[1].split(' ')[0].to_i - wins
    rounds = lmparts[1].split(" ")[0]
    # contains lifetime stats
    misc_data = parsed_html.css('#misc').children[3].children[3]
    # matches won / played
    overall = "#{misc_data.children[15].text.chomp} / #{misc_data.children[11].text.chomp}"
    return "Destiny #{result} a game #{wins}-#{losses} (#{rounds} rounds) (#{overall} games won overall) #{HUMAN_LINK}"
    # output << " as of "
    # output << time_ago_in_words(Time.at(jsn["date"]))
    # output << " ago"
    # # output << " i finished checking at "+time_ago_in_words(Time.now)
    # return output
  end
end
