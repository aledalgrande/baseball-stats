require 'csv'

class Player
  include Mongoid::Document
  include CharacterCheck

  field :first_name, type: String
  field :last_name, type: String
  field :year_of_birth, type: Integer
  field :external_player_id, type: String

  has_many :player_stats

  validate :external_player_id, presence: true

  index({ external_player_id: 1 }, { background: true, unique: true })

  def self.import(filename)
    CSV.foreach(filename, headers: true) do |row|
      player_id = row['playerID']
      first_name = row['nameFirst']
      last_name = row['nameLast']
      year_of_birth = row['birthYear']

      return unless has_valid_characters?(player_id, first_name, last_name, year_of_birth)

      options = { upsert: true, new: true }
      player = Player.where(external_player_id: player_id).find_and_modify({ first_name: first_name, last_name: last_name, year_of_birth: year_of_birth, external_player_id: player_id }, options)
    end
  end
end