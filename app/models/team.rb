class Team
  include Mongoid::Document

  field :external_team_id, type: String

  has_many :player_stats
  belongs_to :league
end