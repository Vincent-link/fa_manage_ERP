class RefactorOrgTeam < ActiveRecord::Migration[6.0]
  def change
    create_join_table :members, :organization_teams
    remove_column :members, :team_ids
  end
end
