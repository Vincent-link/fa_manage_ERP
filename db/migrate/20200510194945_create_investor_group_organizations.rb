class CreateInvestorGroupOrganizations < ActiveRecord::Migration[6.0]
  def change
    create_table :investor_group_organizations do |t|
      t.integer :investor_group_id, comment: '投资组id'
      t.integer :organization_id, comment: '机构id'
      t.integer :tier, comment: '等级'

      t.timestamps
    end

    add_column :investor_group_members, :investor_group_organization_id, :integer, index: true, comment: '投资组机构id'
  end
end
