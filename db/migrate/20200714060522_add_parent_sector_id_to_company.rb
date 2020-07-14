class AddParentSectorIdToCompany < ActiveRecord::Migration[6.0]
  def change
    add_column :companies, :parent_sector_id, :integer
  end
end
