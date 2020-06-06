class CreateContacts < ActiveRecord::Migration[6.0]
  def change
    create_table :contacts do |t|
      t.string  :name
      t.integer :position
      t.string  :email
      t.string  :tel
      t.string  :wechat
      t.references :company, index: true
      t.timestamps
    end
  end
end
