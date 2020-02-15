require 'rails_helper'

describe TeamMembersController, type: :controller do
  let!(:team_member_1) { create(:team_member, section: "Main") }
  let!(:team_member_2) { create(:team_member, section: "Main") }
  let!(:team_member_3) { create(:team_member) }
  let!(:team_member_4) { create(:team_member, section: team_member_3.section) }
  let!(:team_member_5) { create(:team_member) }

  describe "GET #index" do
    it "returns http success" do
      get :index

      expect(response).to have_http_status(:success)
      expect(response).to render_template :index
    end

    it "assigns section_to_member_hash for Main correctly" do
      get :index

      expect(assigns(:section_to_member_hash)).to have_key("MAIN")
      expect(assigns(:section_to_member_hash)["MAIN"].length).to eq(2)
    end

    it "assigns section_to_member_hash for other sections correctly" do
      get :index

      expect(assigns(:section_to_member_hash)).to have_key(team_member_3.section.upcase)
      expect(assigns(:section_to_member_hash)[team_member_3.section.upcase].length).to eq(2)

      expect(assigns(:section_to_member_hash)).to have_key(team_member_5.section.upcase)
      expect(assigns(:section_to_member_hash)[team_member_5.section.upcase].length).to eq(1)
    end

    it "orders by seq" do
      get :index

      team_members = assigns(:section_to_member_hash)

      expect(team_members[team_member_1.section.upcase]).to eq([team_member_1, team_member_2])
      expect(team_members[team_member_3.section.upcase]).to eq([team_member_3, team_member_4])
      expect(team_members[team_member_5.section.upcase]).to eq([team_member_5])
    end
  end
end
