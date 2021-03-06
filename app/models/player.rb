class Player
  include Mongoid::Document
  include CharacterCheck
  include CSVImport

  field :first_name, type: String
  field :last_name, type: String
  field :year_of_birth, type: Integer
  field :external_player_id, type: String

  has_many :player_stats

  validate :external_player_id, presence: true

  index({ external_player_id: 1 }, { background: true, unique: true })

  def self.import(filename)
    import_csv(filename) do |row, db_options|
      player_id = row['playerID']
      first_name = row['nameFirst']
      last_name = row['nameLast']
      year_of_birth = row['birthYear']

      return unless has_valid_characters?(player_id, first_name, last_name, year_of_birth)

      attributes = {
        first_name: first_name,
        last_name: last_name,
        year_of_birth: year_of_birth,
        external_player_id: player_id
      }

      Player.where(external_player_id: player_id).find_and_modify(attributes, db_options)
    end
  end

  def full_name
    "#{self.first_name} #{self.last_name}"
  end
end