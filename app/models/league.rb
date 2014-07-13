class League
  include Mongoid::Document

  field :external_league_id, type: String

  has_many :teams
end