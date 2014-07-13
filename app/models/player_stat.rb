class PlayerStat
  include Mongoid::Document
  include CharacterCheck

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

  def self.import(filename)
    CSV.foreach(filename, headers: true) do |row|
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

      options = { upsert: true, new: true }
      league = League.where(external_league_id: external_league_id).find_and_modify({ external_league_id: external_league_id }, options)
      team = Team.where(external_team_id: external_team_id).find_and_modify({ external_team_id: external_team_id, league_id: league.id }, options)
      player = Player.where(external_player_id: external_player_id).find_and_modify({ external_player_id: external_player_id }, options)

      attributes = {
        player_id: player.id || 0,
        team_id: team.id || 0,
        year: year || 0,
        at_bats: at_bats || 0,
        hits: hits || 0,
        doubles: doubles || 0,
        triples: triples || 0,
        home_runs: home_runs || 0,
        runs_batted_in: runs_batted_in || 0
      }

      player_stat = PlayerStat.where(player_id: player.id, team_id: team.id, year: year).find_and_modify(attributes, options)
    end
  end
end