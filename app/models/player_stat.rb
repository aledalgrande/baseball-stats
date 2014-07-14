class PlayerStat
  include Mongoid::Document
  include CharacterCheck
  include CSVImport

  field :year, type: Integer
  field :at_bats, type: Integer
  field :hits, type: Integer
  field :doubles, type: Integer
  field :triples, type: Integer
  field :home_runs, type: Integer
  field :runs_batted_in, type: Integer

  belongs_to :player
  belongs_to :team

  validate player_id: 1, year: 1, team_id: 1, presence: true

  index({ player_id: 1, team_id: 1, year: 1 }, { background: true, unique: true })
  index({ year: 1, at_bats: 1, player_id: 1 }, { background: true })

  def self.import(filename)
    import_csv(filename) do |row, db_options|
      external_player_id = row['playerID']
      year = row['yearID']
      at_bats = row['AB']
      hits = row['H']
      doubles = row['2B']
      triples = row['3B']
      home_runs = row['HR']
      runs_batted_in = row['RBI']
      external_team_id = row['teamID']
      external_league_id = row['league']

      next unless has_valid_characters?(external_player_id, at_bats, hits, doubles, triples, home_runs, runs_batted_in, external_team_id, external_league_id)

      league = League.where(external_league_id: external_league_id).find_and_modify({ external_league_id: external_league_id }, db_options)
      team = Team.where(external_team_id: external_team_id).find_and_modify({ external_team_id: external_team_id, league_id: league.id }, db_options)
      player = Player.where(external_player_id: external_player_id).find_and_modify({ external_player_id: external_player_id }, db_options)

      attributes = {
        player_id: player.id,
        team_id: team.id,
        year: year.to_i,
        at_bats: at_bats.to_i,
        hits: hits.to_i,
        doubles: doubles.to_i,
        triples: triples.to_i,
        home_runs: home_runs.to_i,
        runs_batted_in: runs_batted_in.to_i
      }

      player_stat = PlayerStat.where(player_id: player.id, team_id: team.id, year: year).find_and_modify(attributes, db_options)
    end
  end

  def self.most_improved_batting_average(year_start, year_end)
    year_start = year_start.to_i
    year_end = year_end.to_i
    player_stats_2009 = PlayerStat.where(year: year_start).gte(at_bats: 200)
    player_stat_groups = player_stats_2009.group_by { |player_stat| player_stat.player_id }
    player_stats_2010 = PlayerStat.where(year: year_end).gte(at_bats: 200).in(player_id: player_stat_groups.keys)

    player_stats_2010.each do |player_stat|
      player_id = player_stat.player_id
      player_stat_groups[player_id] ||= []
      player_stat_groups[player_id] << player_stat
    end

    best_improvement = 0  # 0%
    player_id_best_improvement = nil

    player_stat_groups.each do |player_id, player_stat_group|
      next if player_stat_group.size < 2

      player_stat_2009 = player_stat_group[0]
      player_stat_2010 = player_stat_group[1]
      avg_2009 = batting_average(player_stat_2009.hits, player_stat_2009.at_bats)
      avg_2010 = batting_average(player_stat_2010.hits, player_stat_2010.at_bats)
      improvement = (avg_2010 / avg_2009 - 1) * 100

      if improvement > best_improvement
        best_improvement = improvement
        player_id_best_improvement = player_id
      end
    end

    if player_id_best_improvement
      player = Player.find(player_id_best_improvement)

      return [player, best_improvement]
    end

    return [nil, 0]
  end

  def self.team_slugging_percentage(external_team_id, year)
    external_team_id.upcase!
    team = Team.where(external_team_id: external_team_id).first
    return [] unless team
    team_player_stats = PlayerStat.where(team_id: team.id, year: year).to_a
    return [] if team_player_stats.empty?
    players = Player.in(_id: team_player_stats.map(&:player_id)).group_by { |pl| pl.id }

    team_player_stats.map do |ps|
      player = players[ps.player_id].first
      slugging_percentage = (ps.hits - ps.doubles - ps.triples - ps.home_runs + 2 * ps.doubles + 3 * ps.triples + 4 * ps.home_runs) * 1.0 / ps.at_bats * 100
      slugging_percentage = 0.0 if slugging_percentage.nan?

      { "#{player.first_name} #{player.last_name}" => slugging_percentage }
    end.inject(&:merge)
  end

  def self.triple_crown(year, external_league_id)
    external_league_id.upcase!
    league = League.where(external_league_id: external_league_id).first
    return unless league
    league_teams = Team.where(league_id: league.id).to_a
    year_player_stats = PlayerStat.where(year: year).in(team_id: league_teams).gte(at_bats: 400).to_a
    return if year_player_stats.empty?
    highest_batting_average_player_id = year_player_stats.map { |ps| [ps.player_id, -batting_average(ps.hits, ps.at_bats)] }.sort_by { |stat| stat[1] }.first[0]
    highest_home_runs_player_id = year_player_stats.map { |ps| [ps.player_id, -ps.home_runs] }.sort_by { |stat| stat[1] }.first[0]
    highest_runs_batted_in_player_id = year_player_stats.map { |ps| [ps.player_id, -ps.runs_batted_in] }.sort_by { |stat| stat[1] }.first[0]

    if (highest_batting_average_player_id == highest_home_runs_player_id && highest_home_runs_player_id == highest_runs_batted_in_player_id)
      return Player.find(highest_runs_batted_in_player_id)
    end
  end

  private
  def self.batting_average(hits, at_bats)
    return 0 if at_bats == 0
    hits * 1.0 / at_bats
  end
end