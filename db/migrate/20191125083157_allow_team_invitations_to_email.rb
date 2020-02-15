class AllowTeamInvitationsToEmail < ActiveRecord::Migration[5.2]
  def change
    # create new table
    create_table :email_invitations do |t|
      t.references :invitor, foreign_key: { to_table: :participants }, null: false
      t.citext :email, null: false
      t.citext :token, null: false
      t.references :claimant, foreign_key: { to_table: :participants }
      t.timestamp :claimed_at
      t.timestamps

      t.index :email
      t.index :token, unique: true
    end

    # convert team_invitations table
    reversible do |dir|
      dir.up do
        invitee_from_participant_to_polymorphic
      end
      dir.down do
        invitee_from_polymorphic_to_participant
      end
    end
  end

  private def invitee_from_participant_to_polymorphic
    # rename existing invitee ref
    rename_column :team_invitations, :invitee_id, :old_invitee_id
    # add polymorphic ref
    add_reference :team_invitations, :invitee, polymorphic: true, index: false
    # add index, unique where invitee type is EmailInvitation
    add_index :team_invitations, [:invitee_type, :invitee_id], unique: true, where: %q{invitee_type = 'EmailInvitation'}
    # populate values
    execute <<~SQL
      UPDATE team_invitations
      SET
        invitee_type = 'Participant',
        invitee_id = old_invitee_id;
    SQL
    # add null constraints
    change_column_null :team_invitations, :invitee_type, false
    change_column_null :team_invitations, :invitee_id, false
    # remove old col
    remove_column :team_invitations, :old_invitee_id
  end

  private def invitee_from_polymorphic_to_participant
    # rename existing invitee refs
    rename_column :team_invitations, :invitee_type, :old_invitee_type
    rename_column :team_invitations, :invitee_id, :old_invitee_id
    # add participant ref
    add_reference :team_invitations, :invitee, foreign_key: { to_table: :participants }
    # remove impossible rows
    execute <<~SQL
      DELETE FROM team_invitations
      WHERE old_invitee_type <> 'Participant';
    SQL
    # populate values
    execute <<~SQL
      UPDATE team_invitations
      SET invitee_id = old_invitee_id;
    SQL
    # add null constraint
    change_column_null :team_invitations, :invitee_id, false
    # remove old cols
    remove_column :team_invitations, :old_invitee_type
    remove_column :team_invitations, :old_invitee_id
  end
end
