class AddSectorToCompany < ActiveRecord::Migration[6.0]
  def change
    add_column :companies, :sector_id, :integer
  end
end
