require 'commander'
require 'json'
require 'net/http'
require 'uri'

class MyApplication
  include Commander::Methods

  def run
    program :name, 'Baseball stats'
    program :version, '1.0.0'
    program :description, 'Gives statistics about baseball players.'

    @username = ENV['BASEBALL_STATS_USERNAME']
    @password = ENV['BASEBALL_STATS_PASSWORD']
    @server_uri = ENV['BASEBALL_STATS_SERVER_URI']

    if !@username || !@password || !@server_uri
      say 'Environment variables not found'
      return
    end

    command :miba do |c|
      c.syntax = 'ruby baseball-stats.rb miba'
      c.description = 'Most improved batting average'
      c.option '--ystart YEAR_START', String, '4 digits year'
      c.option '--yend YEAR_END', String, '4 digits year'

      c.action do |args, options|
        say 'Most improved batting average'

        response_body = make_request('/player_stats/most_improved_batting_average', { year_start: options.ystart, year_end: options.yend })
        hash = response_body['most_improved_batting_average']
        say("#{hash['player']}: #{hash['average'].to_f.round(2)}% up between #{options.ystart} and #{options.yend}")
      end
    end

    command :tsp do |c|
      c.syntax = 'ruby baseball-stats.rb tsp'
      c.description = 'Team slugging percentage'
      c.option '--team_id TEAM_ID', String, '3 letters team id'
      c.option '--year YEAR', String, '4 digits year'

      c.action do |args, options|
        say 'Team slugging percentage'

        response_body = make_request('/player_stats/team_slugging_percentage', { external_team_id: options.team_id, year: options.year })
        percentages = response_body['team_slugging_percentage']
        say "Team #{options.team_id}"
        percentages.each do |percentage|
          say "#{percentage['player']}: #{percentage['percentage'].round(3).to_s[1..-1].ljust(4, '0')}"
        end
      end
    end

    command :tc do |c|
      c.syntax = 'ruby baseball-stats.rb tc'
      c.description = 'Triple crown'
      c.option '--league LEAGUE_ID', String, '2 letters league'
      c.option '--year YEAR', String, '4 digits year'

      c.action do |args, options|
        say 'Triple crown'

        response_body = make_request('/player_stats/triple_crown', { year: options.year, league: options.league })
        triple = response_body['triple_crown']
        say "Winner of triple crown for #{options.league} in #{options.year}: #{triple['player']}"
      end
    end

    run!
  end

  private
  def make_request(uri, options)
    uri = URI.parse("#{@server_uri}/#{uri}")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    request.set_form_data(options)
    request.basic_auth(@username, @password)
    response = http.request(request)
    JSON.parse(response.body)
  end
end

MyApplication.new.run if $0 == __FILE__