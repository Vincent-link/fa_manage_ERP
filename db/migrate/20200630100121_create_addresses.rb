class CreateAddresses < ActiveRecord::Migration[6.0]
  def change
    create_table :addresses do |t|
      t.integer :location_id
      t.string :address_desc
      t.timestamp :deleted_at
      t.integer :user_id

      t.timestamps
    end

    execute "ALTER SEQUENCE addresses_id_seq RESTART WITH 100000;"
    Address.create location_id: 52, address_desc: '工人体育场北路甲2号盈科中心捌坊1号'
  end
end
