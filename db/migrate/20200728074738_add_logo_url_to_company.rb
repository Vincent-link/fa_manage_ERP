class AddLogoUrlToCompany < ActiveRecord::Migration[6.0]
  def change
    add_column :companies, :logo_url, :string
  end
end
