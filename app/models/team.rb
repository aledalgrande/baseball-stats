class Team
  include Mongoid::Document

  field :external_team_id, type: String

  validate :external_team_id, presence: true

  has_many :player_stats
  belongs_to :league

  index({ external_team_id: 1 }, { background: true, unique: true })
end