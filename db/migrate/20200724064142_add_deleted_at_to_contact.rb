class AddDeletedAtToContact < ActiveRecord::Migration[6.0]
  def change
    add_column :contacts, :deleted_at, :timestamp, index: true
  end
end
