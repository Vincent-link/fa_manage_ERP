class ChangeMemberColumns2 < ActiveRecord::Migration[6.0]
  def change
    remove_column :organizations, :invest_period
    add_column :organizations, :invest_period_id, :integer

    add_column :members, :intro, :string, comment: '简介'
  end
end
