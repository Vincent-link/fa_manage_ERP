class AddTypeInFunding < ActiveRecord::Migration[6.0]
  def change
    add_column :fundings, :type, :string, comment: '项目的单表继承字段'
    add_index :fundings, :type

    FundingPolymer.update_all(type: 'Funding')
  end
end
