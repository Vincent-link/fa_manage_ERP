class CreateInvestorGroupMembers < ActiveRecord::Migration[6.0]
  def change
    create_table :investor_group_members do |t|
      t.integer :investor_group_id
      t.integer :member_id

      t.timestamps
    end
  end
end
