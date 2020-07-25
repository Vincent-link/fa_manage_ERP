class AddSynAtToCompany < ActiveRecord::Migration[6.0]
  def change
    add_column :companies, :syn_at, :datetime, comment: "同步时间"
  end
end
