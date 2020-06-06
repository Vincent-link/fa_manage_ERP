class DeleteIntroUrlFromCompany < ActiveRecord::Migration[6.0]
  def change
    remove_column :companies, :url
    remove_column :companies, :intro
  end
end
