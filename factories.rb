FactoryGirl.define do
  factory :player do
    first_name { (0...10).map { ('a'..'z').to_a[rand(26)] }.join }
    last_name { (0...10).map { ('a'..'z').to_a[rand(26)] }.join }
    external_player_id { (0...10).map { ('a'..'z').to_a[rand(26)] }.join }
  end

  factory :player_stat do
    year { (1903...1999).sort_by { rand }.first }
    player_id { BSON::ObjectId.new }
    team_id { BSON::ObjectId.new }
    hits 20
    doubles 10
    triples 5
    home_runs 1
    at_bats 200
  end

  factory :team do
    external_team_id 'NYA'
  end
end