class AddStatisTitleToKpi < ActiveRecord::Migration[6.0]
  def change
    add_column :kpis, :statis_title, :string
  end
end
