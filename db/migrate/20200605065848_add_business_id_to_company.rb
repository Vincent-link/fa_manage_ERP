class AddBusinessIdToCompany < ActiveRecord::Migration[6.0]
  def change
    add_column :companies, :business_id, :integer
  end
end
