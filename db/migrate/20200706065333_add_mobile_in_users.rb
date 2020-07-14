class AddMobileInUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :mobile, :string, comment: '电话'
  end
end
