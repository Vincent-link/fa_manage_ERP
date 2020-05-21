class CreateCompanies < ActiveRecord::Migration[6.0]
  def change
    create_table :companies do |t|
      t.string :name
      t.string :intro
      t.string :url
      t.timestamp :deleted_at

      t.timestamps
    end
  end
end
