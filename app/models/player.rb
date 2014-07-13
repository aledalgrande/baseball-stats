require 'csv'

class Player
  include Mongoid::Document
  include CharacterCheck

  field :first_name, type: String
  field :last_name, type: String
  field :year_of_birth, type: Integer
  field :player_id, type: String

  validate :player_id, presence: true

  index({ player_id: 1 }, { background: true, unique: true })

  def self.import(filename)
    CSV.foreach(filename, headers: true) do |row|
      player_id = row['playerID']
      first_name = row['nameFirst']
      last_name = row['nameLast']
      year_of_birth = row['birthYear']

      return if check_invalid_characters(player_id, first_name, last_name, year_of_birth)

      player = Player.collection.find(player_id: player_id).upsert(first_name: first_name, last_name: last_name, year_of_birth: year_of_birth, player_id: player_id)
    end
  end
end