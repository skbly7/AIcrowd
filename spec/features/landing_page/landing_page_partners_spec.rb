require 'rails_helper'

describe "partner visibility" do
  let!(:p1) { create :partner, seq: 1 }
  let!(:p2) { create :partner, seq: 2 }
  let!(:p3) { create :partner, seq: 3 }
  let!(:p4) { create :partner, seq: 4 }
  let!(:p5) { create :partner, seq: 5 }
  let!(:p6) { create :partner, seq: 6 }
  let!(:p7) { create :partner, seq: 7 }
  let!(:p8) { create :partner, seq: 8 }
  let!(:p9) { create :partner, seq: 9 }

  it 'partners visible' do
    visit "/"
    # expect(page).to have_css(".users-group-1", count: 4)
    expect(page).to have_css(".logos-organizers", count: 1)
  end
end
