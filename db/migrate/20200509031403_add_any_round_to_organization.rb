class AddAnyRoundToOrganization < ActiveRecord::Migration[6.0]
  def change
    add_column :organizations, :any_round, :boolean, default: false, comment: '可投任意轮次'
    add_column :organizations, :invest_period, :string, comment: '投资周期'
    add_column :organizations, :decision_flow, :string, comment: '投资决策流程'
    add_column :organizations, :ic_rule, :string, comment: '投委会机制'
    add_column :organizations, :alias, :string, array: true, comment: '机构别名'
  end
end
