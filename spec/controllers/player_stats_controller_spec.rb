require 'rails_helper'

RSpec.describe PlayerStatsController, :type => :controller do
  before(:each) do
    user = 'dhh'
    pw = 'secret'
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(user,pw)
  end

  context "GET most_improved_batting_average" do
    subject { get 'most_improved_batting_average', year_start: 2009, year_end: 2010 }

    it "should return 200" do
      subject
      expect(response).to be_ok
    end

    it "should return the most improved batting average" do
      player = create(:player)
      expect(PlayerStat).to receive(:most_improved_batting_average).with('2009', '2010').and_return([player, 0.300])
      subject
      expect(response.body).to eq({ most_improved_batting_average: { player: player.full_name, average: 0.300 } }.to_json)
    end
  end

  context "GET team_slugging_percentage" do
    subject { get 'team_slugging_percentage', external_team_id: 'OAK', year: 2007 }

    it "should return 200" do
      subject
      expect(response).to be_ok
    end

    it "should return the slugging average for all of the components of the team" do
      expect(PlayerStat).to receive(:team_slugging_percentage).with('OAK', '2007').and_return({ 'Joe Santana' => 0.403, 'Mike Bianchi' => 0.218 })
      subject
      expect(response.body).to eq({ team_slugging_percentage: [ { player: 'Joe Santana', percentage: 0.403 }, { player: 'Mike Bianchi', percentage: 0.218 } ] }.to_json)
    end
  end

  context "GET triple_crown" do
    subject { get 'triple_crown', year: 2012, league: 'AL' }

    it "should return 200" do
      subject
      expect(response).to be_ok
    end

    it "should return the slugging average for all of the components of the team" do
      player = create(:player)
      expect(PlayerStat).to receive(:triple_crown).with('2012', 'AL').and_return(player)
      subject
      expect(response.body).to eq({ triple_crown: { player: player.full_name } }.to_json)
    end

    context "when there is no winner" do
      it "should return (No winner)" do
        expect(PlayerStat).to receive(:triple_crown).with('2012', 'AL').and_return(nil)
        subject
        expect(response.body).to eq({ triple_crown: { player: "(No winner)" } }.to_json)
      end
    end
  end
end
