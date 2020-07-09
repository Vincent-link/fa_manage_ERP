class AddTeamLevelToTeams < ActiveRecord::Migration[6.0]
  def change
    add_column :sso_teams, :level, :integer
  end
end
