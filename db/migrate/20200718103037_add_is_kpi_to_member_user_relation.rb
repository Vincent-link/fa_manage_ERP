class AddIsKpiToMemberUserRelation < ActiveRecord::Migration[6.0]
  def change
    add_column :member_user_relations, :is_kpi, :boolean, default: false, comment: '是否用于kpi统计'
  end
end
