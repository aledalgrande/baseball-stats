# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

namespace :player_stats do
  desc "Import player stats from CSV"

  task :import => :environment do
    PlayerStat.import(Rails.root + '/data/Batting-07-12.csv')
  end
end

namespace :players do
  desc "Import players from CSV"

  task :import => :environment do
    Player.import(Rails.root + '/data/Master-small.csv')
  end
end