require 'rails_helper'

RSpec.describe PlayerStat, :type => :model do
  context "#import" do
    subject { PlayerStat.import(filename) }

    context "when there are not player stats" do
      let(:filename) { "#{Rails.root}/spec/fixtures/player_stats/player_stats.csv" }

      it "should create new player stats" do
        subject
        expect(PlayerStat.count).not_to eq(0)
      end

      it "should import year" do
        subject
        expect(PlayerStat.first.year).to eq(2012)
      end

      it "should import at-bats" do
        subject
        expect(PlayerStat.first.at_bats).to eq(0)
        player_id = Player.where(external_player_id: 'abadfe01').first.id
        expect(PlayerStat.where(player_id: player_id).first.at_bats).to eq(7)
      end

      it "should import hits" do
        subject
        expect(PlayerStat.last.hits).to eq(10)
      end

      it "should import player id" do
        subject
        player_id = Player.where(external_player_id: 'aardsda01').first.id
        expect(PlayerStat.first.player_id).to eq(player_id)
      end

      it "should import doubles" do
        subject
        expect(PlayerStat.last.doubles).to eq(1)
      end

      it "should import triples" do
        subject
        expect(PlayerStat.last.triples).to eq(3)
      end

      it "should import home runs" do
        subject
        expect(PlayerStat.last.home_runs).to eq(2)
      end

      it "should import runs batted in" do
        subject
        expect(PlayerStat.last.runs_batted_in).to eq(4)
      end
    end

    context "when the league doesn't exist" do
      let(:filename) { "#{Rails.root}/spec/fixtures/player_stats/player_stats.csv" }

      it "should create the league" do
        subject
        expect(League.count).not_to eq(0)
      end

      it "should assign the league to the team" do
        subject
        expect(League.first.teams.count).not_to eq(0)
      end
    end

    context "when the team doesn't exist" do
      let(:filename) { "#{Rails.root}/spec/fixtures/player_stats/player_stats.csv" }

      it "should create the team" do
        subject
        expect(Team.count).not_to eq(0)
      end

      it "should import the league" do
        subject
        expect(Team.first.player_stats.count).not_to eq(0)
      end
    end

    context "when the player doesn't exist" do
      let(:filename) { "#{Rails.root}/spec/fixtures/player_stats/player_stats.csv" }

      it "should create the player" do
        subject
        expect(PlayerStat.count).not_to eq(0)
      end
    end

    context "when the file is empty" do
      let(:filename) { "#{Rails.root}/spec/fixtures/player_stats/player_stats2.csv" }

      it "should not crash" do
        expect(->{ subject }).not_to raise_error
      end
    end

    context "when the file is corrupted" do
      let(:filename) { "#{Rails.root}/spec/fixtures/player_stats/player_stats3.csv" }

      it "should not import it" do
        subject
        expect(PlayerStat.count).to eq(0)
      end
    end
  end

  context "#most_improved_batting_average" do
    let(:players) { create_list(:player, 2) }

    subject { PlayerStat.most_improved_batting_average(2009, 2010) }

    context "when there are players with 200 at-bats or more" do
      let!(:player_stats) { [create(:player_stat, year: 2009, hits: 10, at_bats: 203, player_id: players[0].id), create(:player_stat, year: 2009, hits: 18, at_bats: 210, player_id: players[1].id), create(:player_stat, year: 2010, hits: 10, at_bats: 222, player_id: players[0].id), create(:player_stat, year: 2010, hits: 27, at_bats: 210, player_id: players[1].id)] }

      it "should return the highest batting average improvement with the player" do
        best = subject
        best[1] = best[1].round(1)
        expect(best).to eq([players[1], 50.0])
      end
    end

    context "when there are players with less than 200 at-bats" do
      let!(:player_stats) { [create(:player_stat, year: 2009, hits: 10, at_bats: 190, player_id: players[0].id), create(:player_stat, year: 2009, hits: 18, at_bats: 210, player_id: players[1].id), create(:player_stat, year: 2010, hits: 10, at_bats: 222, player_id: players[0].id), create(:player_stat, year: 2010, hits: 27, at_bats: 210, player_id: players[1].id)] }

      it "should not include those players" do
        best = subject
        best[1] = best[1].round(1)
        expect(best).to eq([players[1], 50.0])
      end
    end
  end

  context "#team_slugging_percentage" do
    subject { PlayerStat.team_slugging_percentage(external_team_id, year) }

    context "when all the parameters are valid" do
      let(:external_team_id) { 'OAK' }
      let(:year) { 2007 }
      let(:players) { create_list(:player, 3) }
      let(:team1) { create(:team, external_team_id: external_team_id) }
      let(:team2) { create(:team) }
      let!(:player_stats) { [create(:player_stat, team: team1, year: 2007, player: players[0]), create(:player_stat, team: team1, year: 2007, player: players[1]), create(:player_stat, team: team2, year: 2007, player: players[2]), create(:player_stat, team: team1, year: 2008, player: players[0])] }

      it "should return the slugging percentage for each member of the team that year" do
        player_stats_2007_team1 = [player_stats[0], player_stats[1]]
        
        slugging_percentages = player_stats_2007_team1.map do |ps|
          { "#{ps.player.first_name} #{ps.player.last_name}" => (ps.hits - ps.doubles - ps.triples - ps.home_runs + 2 * ps.doubles + 3 * ps.triples + 4 * ps.home_runs) * 1.0 / ps.at_bats * 100 }
        end.inject(&:merge)

        expect(subject).to eq(slugging_percentages)
      end

      it "should not return the slugging percentage for other teams" do
        expect(subject.size).to eq(2)
      end

      it "should not return the slugging percentage for other years" do
        expect(subject.size).to eq(2)
      end
    end

    context "when the team id is not found" do
      let(:external_team_id) { 'BRB' }
      let(:year) { 2007 }

      it "should return an empty result" do
        expect(subject).to eq([])
      end
    end

    context "when a certain year is not present in the database" do
      let(:external_team_id) { 'OAK' }
      let(:year) { 1884 }

      it "should return an empty result" do
        expect(subject).to eq([])
      end
    end
  end

  context "triple crown" do
    subject { PlayerStat.triple_crown(year, league) }

    context "when the year is not valid" do
      let(:year) { 1884 }
      let(:league) { 'NL' }

      it "should return a no-winner" do
        expect(subject).to eq(nil)
      end
    end

    context "when the league is not valid" do
      let(:year) { 1884 }
      let(:league) { 'HG' }

      it "should return a no-winner" do
        expect(subject).to eq(nil)
      end
    end

    context "when the player has less than 400 at-bats" do
      let!(:player_stats) { [create(:player_stat, at_bats: 300, year: 2012, hits: 200, home_runs: 14, runs_batted_in: 50)] }
      let(:year) { 2012 }
      let(:league) { 'NL' }

      it "should not be included in the count" do
        expect(subject).to eq(nil)
      end
    end

    context "when the player has 400 at-bats or more" do
      let(:year) { 2012 }
      let(:league) { 'AL' }
      let(:players) { create_list(:player, 2) }
      let(:al) { create(:league, external_league_id: 'AL') }
      let(:teams) { create_list(:team, 2, league_id: al.id) }

      context "when there is a triple crown" do
        let!(:player_stats) { [create(:player_stat, player: players[0], team: teams[0], year: 2012, at_bats: 500, hits: 200, home_runs: 14, runs_batted_in: 50), create(:player_stat, player: players[1], team: teams[1], year: 2012, at_bats: 500, hits: 190, home_runs: 14, runs_batted_in: 50), create(:player_stat, player: players[1], team: teams[1], year: 2012, at_bats: 2, hits: 1, home_runs: 14, runs_batted_in: 50)] }

        it "should return the right winner" do
          expect(subject).to eq(players[0])
        end
      end

      context "when there isn't a triple crown" do
        let!(:player_stats) { [create(:player_stat, player: players[0], team: teams[0], year: 2012, at_bats: 500, hits: 200, home_runs: 14, runs_batted_in: 50), create(:player_stat, player: players[1], team: teams[1], year: 2012, at_bats: 500, hits: 190, home_runs: 14, runs_batted_in: 52), create(:player_stat, player: players[1], team: teams[1], year: 2012, at_bats: 2, hits: 7, home_runs: 0, runs_batted_in: 5)] }

        it "should return a no-winner" do
          expect(subject).to eq(nil)
        end
      end
    end
  end
end