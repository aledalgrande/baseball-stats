FactoryGirl.define do
  factory :player do
    external_player_id { (0...10).map { ('a'..'z').to_a[rand(26)] }.join }
  end

  factory :player_stat do
    year { (1903...1999).sort_by { rand }.first }
    player_id { BSON::ObjectId.new }
    team_id { BSON::ObjectId.new }
  end
end