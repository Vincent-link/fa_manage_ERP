class CreateInvestorGroups < ActiveRecord::Migration[6.0]
  def change
    create_table :investor_groups do |t|
      t.string :name
      t.boolean :is_public
      t.integer :user_id

      t.timestamps
    end
  end
end
