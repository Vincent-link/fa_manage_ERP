class AddAgreeTimeToFunding < ActiveRecord::Migration[6.0]
  def change
    add_column :fundings, :agree_time, :datetime
  end
end
