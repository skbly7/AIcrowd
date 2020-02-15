require 'rails_helper'

describe Team do
  let!(:challenge) { create :challenge, max_team_participants: 3 }
  let!(:team) { create :team, challenge: challenge }

  context 'concreteness' do
    describe 'false with 0 participants' do
      it { expect(team.team_participants.count).to eq(0) }
      it { expect(team.concrete?).not_to be }
    end

    describe 'false with 1 participant' do
      let!(:p1) { create :participant }

      before do
        team.team_participants.create(participant: p1, role: :organizer)
      end

      it { expect(team.team_participants.count).to eq(1) }
      it { expect(team.concrete?).not_to be }
    end

    describe 'true with 2 participants' do
      let!(:p1) { create :participant }
      let!(:p2) { create :participant }

      before do
        team.team_participants.create(participant: p1, role: :organizer)
        team.team_participants.create(participant: p2, role: :member)
      end

      it { expect(team.team_participants.count).to eq(2) }
      it { expect(team.concrete?).to be true }
    end
  end

  context 'Capacity' do
    describe 'not full with 0 participants' do
      it { expect(team.team_participants.count).to eq(0) }
      it { expect(team.invitations_left).to eq(3) }
      it { expect(team.full?).not_to be }
    end

    describe 'not full with 1 participants' do
      let!(:p1) { create :participant }

      before do
        team.team_participants.create(participant: p1, role: :organizer)
      end

      it { expect(team.team_participants.count).to eq(1) }
      it { expect(team.invitations_left).to eq(2) }
      it { expect(team.full?).to be false }
    end

    describe 'full with 3 participants' do
      let!(:p1) { create :participant }
      let!(:p2) { create :participant }
      let!(:p3) { create :participant }

      before do
        team.team_participants.create(participant: p1, role: :organizer)
        team.team_participants.create(participant: p2, role: :member)
        team.team_participants.create(participant: p3, role: :member)
      end

      it { expect(team.team_participants.count).to eq(3) }
      it { expect(team.invitations_left).to eq(0) }
      it { expect(team.full?).to be true }
    end

    describe 'full with more participants than max' do
      let!(:p1) { create :participant }
      let!(:p2) { create :participant }
      let!(:p3) { create :participant }

      before do
        team.team_participants.create(participant: p1, role: :organizer)
        team.team_participants.create(participant: p2, role: :member)
        team.team_participants.create(participant: p3, role: :member)
        challenge.update!(max_team_participants: 2)
      end

      it { expect(team.team_participants.count).to eq(3) }
      it { expect(team.invitations_left).to eq(-1) }
      it { expect(team.invitations_left_clamped).to eq(0) }
      it { expect(team.full?).to be true }
    end

    describe '2 members, 1 invitation' do
      let!(:p1) { create :participant }
      let!(:p2) { create :participant }
      let!(:p3) { create :participant }

      before do
        team.team_participants.create(participant: p1, role: :organizer)
        team.team_participants.create(participant: p2, role: :member)
        team.team_invitations.new(
          invitor: p1,
          invitee: p3
        ).save!
      end

      it { expect(team.team_participants.count).to eq(2) }
      it { expect(team.team_invitations.status_pendings.count).to eq(1) }
      it { expect(team.invitations_left).to eq(0) }
      it { expect(team.full?).to be true }
    end

    describe 'decline/cancel regains invitations' do
      let!(:p1) { create :participant }
      let!(:p2) { create :participant }
      let!(:p3) { create :participant }

      before do
        team.team_participants.create(participant: p1, role: :organizer)
        inv = team.team_invitations.new(
          invitor: p1,
          invitee: p2
        )
        inv.save!
        inv.update!(status: :declined)
        inv = team.team_invitations.new(
          invitor: p1,
          invitee: p3
        )
        inv.save!
        inv.update!(status: :canceled)
      end

      it { expect(team.team_participants.count).to eq(1) }
      it { expect(team.team_invitations.status_pendings.count).to eq(0) }
      it { expect(team.invitations_left).to eq(2) }
      it { expect(team.full?).to be false }
    end
  end
end
