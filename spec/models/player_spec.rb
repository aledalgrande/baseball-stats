require 'rails_helper'

RSpec.describe Player, :type => :model do
  context "#import" do
    subject { Player.import(filename) }

    context "when there is no player" do
      let(:filename) { "#{Rails.root}/spec/fixtures/players/players.csv" }

      it "should create new players" do
        subject
        expect(Player.count).not_to eq(0)
      end

      it "should import the name" do
        subject
        expect(Player.first.first_name).to eq('Hank')
        expect(Player.last.last_name).to eq('Abbey')
      end

      it "should import the year of birth" do
        subject
        expect(Player.first.year_of_birth).to eq(1934)
      end

      it "should import the player id" do
        subject
        expect(Player.first.external_player_id).to eq('aaronha01')
      end
    end

    context "when there are players already" do
      let(:filename) { "#{Rails.root}/spec/fixtures/players/players.csv" }

      before do
        Player.create(external_player_id: 'aaronha01', year_of_birth: 1922, first_name: 'Hank', last_name: 'Aaron')
      end

      it "should update the player data" do
        subject
        expect(Player.where(external_player_id: 'aaronha01').first.year_of_birth).to eq(1934)
      end
    end

    context "when the file is empty" do
      let(:filename) { "#{Rails.root}/spec/fixtures/players/players2.csv" }

      it "should not crash" do
        expect(->{ subject }).not_to raise_error
      end
    end

    context "when the file is corrupted" do
      let(:filename) { "#{Rails.root}/spec/fixtures/players/players3.csv" }

      it "should not import it" do
        subject
        expect(Player.count).to eq(0)
      end
    end
  end
end
