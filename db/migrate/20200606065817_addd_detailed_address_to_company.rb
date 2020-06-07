class AdddDetailedAddressToCompany < ActiveRecord::Migration[6.0]
  def change
    add_column :companies, :detailed_address, :string 
  end
end
