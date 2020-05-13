class CreateOrganizationRelations < ActiveRecord::Migration[6.0]
  def change
    create_table :organization_relations do |t|
      t.integer :organization_id, index: true, comment: '机构id'
      t.integer :relation_organization_id, comment: '关联机构id'
      t.integer :relation_type, comment: '关联类型'
      t.timestamps
    end
  end
end
