class ChangePositionIdInFundingCompanyContacts < ActiveRecord::Migration[6.0]
  def change
    remove_column :funding_company_contacts, :position_id
    add_column :funding_company_contacts, :position_id, :integer, comment: '职位'
  end
end
