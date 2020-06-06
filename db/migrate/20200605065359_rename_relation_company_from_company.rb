class RenameRelationCompanyFromCompany < ActiveRecord::Migration[6.0]
  def change
    remove_column :companies, :relation_company
  end
end
