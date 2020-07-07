class Kpi < ApplicationRecord
  belongs_to :kpi_group
  has_many :conditions, class_name: "Kpi", foreign_key: :parent_id

  include StateConfig

  state_config :kpi_type, config: {
    # kind:2 bd负责人，上传el为新签，status:7为完成，新签和完成的项目需要满足融资额和收入条件
    new_sign_bd_goal: {               value: 1, desc: "BD总体目标（新签）", unit: "个", is_system: true,
      op: -> (user_id) {
        Funding.includes(:funding_users).where(funding_users: {user_id: 1988, kind: 2}).select{|e| e if !e.file_el_attachment.nil? && e.pipelines.where(status: 7).map {|e| transform_to_usd(e.total_fee, e.total_fee_currency)}.sum >= 400000 || e.pipelines.where(status: 7).map {|e| transform_to_usd(e.total_fee, e.total_fee_currency)}.sum >= 10000000}
    },
    complete_bd_goal: {               value: 2, desc: "BD总体目标（完成）", unit: "个", is_system: true,
      op: -> (user_id) {
        Funding.includes(:funding_users).where(funding_users: {user_id: 1988, kind: 2}, status: 7).select{|e| e.pipelines.where(status: 7).map {|e| transform_to_usd(e.total_fee, e.total_fee_currency)}.sum >= 40 || e.pipelines.where(status: 7).map {|e| transform_to_usd(e.total_fee, e.total_fee_currency)}.sum >= 10000000}
    },

    new_sign_growth_bd_goal_for_pe: { value: 3, desc: "asso/PE及以下成长期BD目标(新签)", unit: "个", is_system: true,
      op: -> (user_id) {
        Funding.includes(:funding_users).where(funding_users: {user_id: user_id, kind: 2}).select{|e| e if !e.file_el_attachment.nil? && compare_target_amount(e.target_amount, e.target_amount_currency, 150000000, 3)}.count
      }
    },
    new_sign_growth_bd_for_vp: {      value: 3, desc: "VP成长期BD目标(新签)", unit: "个", is_system: true,
      op: -> (user_id) {
        Funding.includes(:funding_users).where(funding_users: {user_id: user_id, kind: 2}).select{|e| e if !e.file_el_attachment.nil? && compare_target_amount(e.target_amount, e.target_amount_currency, 300000000, 3)}.count
      }
    },
    new_sign_growth_bd_for_director: {value: 3, desc: "Director成长期BD目标(新签)", unit: "个", is_system: true,
      op: -> (user_id) {
        Funding.includes(:funding_users).where(funding_users: {user_id: user_id, kind: 2}).select{|e| e if !e.file_el_attachment.nil? && compare_target_amount(e.target_amount, e.target_amount_currency, 500000000, 3)}.count
      }
    },

    complete_growth_bd_for_pe: {      value: 3, desc: "asso/PE及以下成长期BD目标(完成)", unit: "个", is_system: true,
      op: -> (user_id) {
        Funding.includes(:funding_users).where(funding_users: {user_id: user_id, kind: 2}, status: 7).select{|e| e if compare_target_amount(e.target_amount, e.target_amount_currency, 150000000, 3)}.count
      }
    },
    complete_growth_bd_for_vp: {      value: 3, desc: "VP成长期BD目标(完成)", unit: "个", is_system: true,
      op: -> (user_id) {
        Funding.includes(:funding_users).where(funding_users: {user_id: user_id, kind: 2}, status: 7).select{|e| e if compare_target_amount(e.target_amount, e.target_amount_currency, 300000000, 3)}.count
      }
    },
    complete_growth_bd_for_director: { value: 3, desc: "Director成长期BD目标(完成)", unit: "个", is_system: true,
      op: -> (user_id) {
        Funding.includes(:funding_users).where(funding_users: {user_id: user_id, kind: 2}, status: 7).select{|e| e if compare_target_amount(e.target_amount, e.target_amount_currency, 500000000, 3)}.count
      }
    },

    visit_company: {                  value: 5, desc: "拜访公司", unit: "个", is_system: true,
      op: -> (user_id){
        # 类别为约见公司，且约见已完成
        Calendar.where(user_id: user_id, meeting_category: 2, status: 3).count
      }
    },
    visit_investor: {                 value: 6, desc: "拜访投资人", unit: "个", is_system: true,
      op: -> (user_id){
        # 类别为约见投资人，且约见已完成
        Calendar.where(user_id: user_id, meeting_category: 3, status: 3).count
      }
    },
    dept_coverage_investor: {         value: 7, desc: "投资人深度覆盖", unit: "个", is_system: true,
      op: -> (user_id){
        # 覆盖的投资人 todolist 等覆盖投资人那块
        Member.where(user_id: user_id).count
      }
    },

    # alpha组
    delivery_projects_number: {       value: 7, desc: "交割项目数量", unit: "个", is_system: true,
      op: -> (user_id){
        # status:paid
        Funding.includes(:funding_users).where(funding_users: {user_id: user_id, kind: 1}, status: 7).count
      }
    },
    income_from_delivery_projects: {  value: 8, desc: "交割项目收入", unit: "万", is_system: true,
      op: -> (user_id){
        user = User.find(user_id)
        # status:paid，收入大于150万美元
        Funding.includes(:funding_users).where(funding_users: {user_id: user_id, kind: 1}, status: 7).select{|e| e.pipelines.where(status: 7).map {|e| transform_to_usd(e.total_fee, e.total_fee_currency)}.sum >= 1500000 }.count
      }
    },
    completion_of_medical_projects: { value: 9, desc: "完成医疗项目(不在系统统计)", unit: "个", is_system: false,
      op: ""
    },
    execution_of_medical_projects: {  value: 10, desc: "执行医疗项目(不在系统统计)", unit: "个", is_system: false,
      op: ""
    },
    growth_projects: {                value: 11, desc: "成长期项目(不在系统统计)", unit: "个", is_system: false,
      op: ""
    },

    # 执行组
    project_execution: {              value: 12, desc: "项目执行", unit: "个", is_system: true,
      op: -> (user_id){
        # 担任项目成员即可
        Funding.includes(:funding_users).where(funding_users: {user_id: user_id, kind: 1}, status: 7).count
      }
    },
    project_quality_scoring: {        value: 13, desc: "项目质量评分", unit: "分", is_system: true,
      op: ""
      # todolist等客户评价
    },
    uploading_industry_reports: {     value: 14, desc: "上传行业报告", unit: "个", is_system: true,
      op: -> (user_id){
        # 上传行业报告
        ActiveStorage::Blob.where(user_id: user_id).map(&:attachments).flatten.count
      }
    },
    serving_as_project_po: {          value: 7, desc: "担任项目PO", unit: "个", is_system: true,
      op: -> (user_id){
        # 担任执行负责人
        Funding.includes(:funding_users).where(funding_users: {user_id: user_id, kind: 3}, status: 7).count
      }
    },
    complex_projects: {               value: 7, desc: "复杂项目", unit: "个", is_system: true,
      op: -> (user_id, coverage){
        if !coverage.nil?
          teams = Team.find(coverage).sub_teams.append(Team.find(coverage))
          # 团队的所有成员参与的复杂项目数量 + 自己参与的复杂项目数量
          fundings = teams.users.uniq.map {|user| user.funding if user.funding.is_complicated == true}
        else
          fundings = user.funding if user.funding.is_complicated == true
        end
        fundings.count
      }
    },

    # ka策略组
    execution_ka_project_po: {        value: 7, desc: "KA项目PO（执行）", unit: "个", is_system: true,
      op: -> (user_id){
        Funding.includes(:funding_users).where(funding_users: {user_id: user_id, kind: 3}, is_ka: true).count
      }
    },
    complete_ka_project_po: {         value: 7, desc: "KA项目PO（完成）", unit: "个", is_system: true,
      op: -> (user_id){
        Funding.includes(:funding_users).where(funding_users: {user_id: user_id, kind: 3}, is_ka: true, status: 7).count
      }
    },
    depth_communicate_of_organ: {     value: 7, desc: "机构深度沟通（不在系统统计）", unit: "个", is_system: false,
      op: ""
    },
    project_recommendation: {         value: 7, desc: "项目推荐（不在系统统计）", unit: "个", is_system: false,
      op: ""
    },

    new_sign_ma_project: {            value: 7, desc: "新签并购项目", unit: "个", is_system: true,
      op: ""
    },

  }

  # 计算项目融资额
  def compare_target_amount(target_amount, target_amount_currency, kpi_target_amount, kpi_target_amount_currency)
    target_amount >= kpi_target_amount && target_amount_currency == kpi_target_amount_currency || target_amount >= ConfigBox.rmb_usd_rate * kpi_target_amount && target_amount_currency == 1 if !target_amount.nil? && !target_amount_currency.nil?
  end

  # 换算美元
  def transform_to_usd(total_fee, total_fee_currency)
    if !total_fee.nil?
      case total_fee_currency
      when 1
        total_fee/ConfigBox.rmb_usd_rate
      when 3
        total_fee
      end
    end
  end
end
