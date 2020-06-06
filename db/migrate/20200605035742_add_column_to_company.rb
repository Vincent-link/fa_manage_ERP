class AddColumnToCompany < ActiveRecord::Migration[6.0]
  def change
    add_column :companies, :location_province_id, :integer
    add_column :companies, :location_city_id, :integer
    add_column :companies, :relation_company, :string
    add_column :companies, :website, :string
    add_column :companies, :one_sentence_intro, :string
    add_column :companies, :detailed_intro, :text
    add_column :companies, :recent_financing, :string
    add_column :companies, :callreport_num, :integer
    add_column :companies, :is_ka, :boolean
  end
end
