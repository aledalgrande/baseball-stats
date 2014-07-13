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
end