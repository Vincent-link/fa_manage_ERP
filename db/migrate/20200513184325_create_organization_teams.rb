class CreateOrganizationTeams < ActiveRecord::Migration[6.0]
  def change
    create_table :organization_teams do |t|
      t.integer :organization_id
      t.string :name

      t.timestamps
    end

    remove_column :members, :team
    add_column :members, :team_ids, :integer, array: true, comment: '所属机构团队'
  end
end
