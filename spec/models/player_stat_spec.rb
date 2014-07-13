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
end