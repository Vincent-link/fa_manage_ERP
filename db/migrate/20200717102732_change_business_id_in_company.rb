class ChangeBusinessIdInCompany < ActiveRecord::Migration[6.0]
  def change
    rename_column :companies, :business_id, :registered_name
    change_column :companies, :registered_name, :string
  end
end
