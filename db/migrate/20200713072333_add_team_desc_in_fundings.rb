class AddTeamDescInFundings < ActiveRecord::Migration[6.0]
  def change
    add_column :fundings, :team_desc, :string, comment: '团队介绍'
  end
end
