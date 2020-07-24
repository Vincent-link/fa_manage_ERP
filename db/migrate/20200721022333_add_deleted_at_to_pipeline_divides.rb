class AddDeletedAtToPipelineDivides < ActiveRecord::Migration[6.0]
  def change
    add_column :pipeline_divides, :deleted_at, :datetime, comment: '软删除'
    add_index :pipeline_divides, :deleted_at
  end
end
