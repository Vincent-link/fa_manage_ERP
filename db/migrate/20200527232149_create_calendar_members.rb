class CreateCalendarMembers < ActiveRecord::Migration[6.0]
  def change
    create_table :calendar_members do |t|
      t.integer :calendar_id, index: true
      t.integer :memberable_id
      t.string :memberable_type

      t.timestamps
    end
  end
end
