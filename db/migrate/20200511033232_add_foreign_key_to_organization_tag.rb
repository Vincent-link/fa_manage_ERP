class AddForeignKeyToOrganizationTag < ActiveRecord::Migration[6.0]
  def change
  	add_column :organization_tags, :organization_tag_category_id, :integer
  end
end
