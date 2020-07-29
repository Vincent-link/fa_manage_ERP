class AddDeletedAtToPipeline < ActiveRecord::Migration[6.0]
  def change
    add_column :pipelines, :deleted_at, :datetime, comment: '软删除'
  end
end
