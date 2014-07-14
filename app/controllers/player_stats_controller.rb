class PlayerStatsController < ApplicationController
  def most_improved_batting_average
    result = PlayerStat.most_improved_batting_average(params[:year_start], params[:year_end])
    render json: { most_improved_batting_average: { player: result[0], average: result[1] } }.to_json
  end

  def team_slugging_percentage
    result = PlayerStat.team_slugging_percentage(params[:external_team_id], params[:year]).map { |slugging| { player: slugging[0], percentage: slugging[1] } }
    render json: { team_slugging_percentage: result }.to_json
  end

  def triple_crown
    player = PlayerStat.triple_crown(params[:year], params[:league])
    player_name = player ? "#{player.first_name} #{player.last_name}" : "(No winner)"
    render json: { triple_crown: { player: player_name } }.to_json
  end
end
