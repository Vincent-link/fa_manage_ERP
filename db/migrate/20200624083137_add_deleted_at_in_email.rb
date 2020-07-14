class AddDeletedAtInEmail < ActiveRecord::Migration[6.0]
  def change
    add_column :emails, :deleted_at, :datetime
    add_index :emails, :deleted_at
  end
end
