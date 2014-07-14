class PlayerStatsController < ApplicationController
  http_basic_authenticate_with name: ENV['BASEBALL_STATS_USERNAME'], password: ENV['BASEBALL_STATS_PASSWORD']

  def most_improved_batting_average
    result = PlayerStat.most_improved_batting_average(params[:year_start], params[:year_end])
    player = result[0]
    player_name = player ? player.full_name : ''
    render json: { most_improved_batting_average: { player: player_name, average: result[1] } }.to_json
  end

  def team_slugging_percentage
    result = PlayerStat.team_slugging_percentage(params[:external_team_id], params[:year]).map { |slugging| { player: slugging[0], percentage: slugging[1] } }
    render json: { team_slugging_percentage: result }.to_json
  end

  def triple_crown
    player = PlayerStat.triple_crown(params[:year], params[:league])
    player_name = player ? player.full_name : "(No winner)"
    render json: { triple_crown: { player: player_name } }.to_json
  end
end
