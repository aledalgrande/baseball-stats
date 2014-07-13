class League
  include Mongoid::Document

  field :external_league_id, type: String

  validate :external_league_id, presence: true

  has_many :teams

  index({ external_league_id: 1 }, { background: true, unique: true })
end