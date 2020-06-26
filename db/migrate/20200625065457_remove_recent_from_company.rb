class RemoveRecentFromCompany < ActiveRecord::Migration[6.0]
  def self.up
    remove_column :companies, :recent_financing
    add_column :companies, :recent_financing, :integer
  end

  def self.down
    remove_column :companies, :recent_financing
    add_column :companies, :recent_financing, :string
  end
end
