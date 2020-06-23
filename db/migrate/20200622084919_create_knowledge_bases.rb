class CreateKnowledgeBases < ActiveRecord::Migration[6.0]
  def change
    create_table :knowledge_bases do |t|
      t.string :name
      t.integer :knowledge_base_type
      t.integer :parent_id

      t.timestamps
    end
  end
end
