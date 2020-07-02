class AddUserIdToPipeline < ActiveRecord::Migration[6.0]
  def change
    add_column :pipelines, :user_id, :integer
  end
end
