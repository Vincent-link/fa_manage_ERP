class CreateFundingUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :funding_users do |t|
      t.belongs_to :funding, index: true
      t.belongs_to :user, index: true
      t.string :kind, comment: '类型'

      t.timestamps
    end
  end
end
