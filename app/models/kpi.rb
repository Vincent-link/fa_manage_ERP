class Kpi < ApplicationRecord
  belongs_to :kpi_group
  has_many :conditions, class_name: "Kpi", foreign_key: :parent_id

  include StateConfig

  state_config :kpi_type, config: {
    new_sign_bd_goal: {
      value: 1,
      desc: "BD总体目标（新签）",
      unit: "个",
      is_system: true,
      op: 2
    },
    complete_bd_goal: {
      value: 2,
      desc: "BD总体目标（完成）",
    }
  }
  # ["new_sign_bd_goal", "complete_bd_goal", "new_sign_growth_bd_goal", "complete_growth_bd_goal", "visit_company", "visit_investor", "dept_coverage_investor"]

end
