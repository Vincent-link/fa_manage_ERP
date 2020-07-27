class CreateCompetingCompanies < ActiveRecord::Migration[6.0]
  def change
    create_table :competing_companies do |t|
      t.integer :company_id, comment: '公司id'
      t.integer :competing_company_id, comment: '竞争公司id'
      t.timestamps
    end
  end
end
