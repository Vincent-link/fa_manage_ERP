class Kpi < ApplicationRecord
  belongs_to :kpi_group
  has_many :conditions, class_name: "Kpi", foreign_key: :parent_id

  include StateConfig

  state_config :kpi_type, config: {
    # kind:2 bd负责人，上传el为新签，status:7为完成，新签和完成的项目需要满足融资额和收入条件
    # 用户为BD负责人：2，收入大于40万或者融资额大于1000万，且上传el
    new_sign_bd_goal: {               value: 1, desc: "BD总体目标（新签）", unit: "个", is_system: true,
      op: -> (user_id, coverage){
        # coverage：nil为个人，否则团队
        if coverage.nil?
          Funding.includes(:funding_users).where(funding_users: {user_id: 1988, kind: 2}).select{|e| e if !e.file_el_attachment.nil? && e.pipelines.where(status: 10).map {|e| transform_to_usd(e.total_fee, e.total_fee_currency)}.sum >= 400000 || e.pipelines.where(status: 10).map {|e| transform_to_usd(e.total_fee, e.total_fee_currency)}.sum >= 10000000}.count
        else
          team = Team.find(coverage)
          teams = team.sub_teams
          teams.append(team).map(&:users).flatten.uniq.map {|user| Funding.includes(:funding_users).where(funding_users: {user_id: user.id, kind: 2}).select{|e| e if !e.file_el_attachment.nil? && e.pipelines.where(status: 10).map {|e| transform_to_usd(e.total_fee, e.total_fee_currency)}.sum >= 400000 || e.pipelines.where(status: 10).map {|e| transform_to_usd(e.est_amount, e.est_amount_currency)}.sum >= 10000000}.count}.sum
        end
      }
    },
    # 用户为BD负责人：2，收入大于40万或者融资额大于1000万，项目状态为paid：7，pipeline状态为已收款：10
    complete_bd_goal: {               value: 2, desc: "BD总体目标（完成）", unit: "个", is_system: true,
      op: -> (user_id) {
        Funding.includes(:funding_users).where(funding_users: {user_id: 1988, kind: 2}, status: 7).select{|e| e.pipelines.where(status: 10).map {|e| transform_to_usd(e.total_fee, e.total_fee_currency)}.sum >= 40 || e.pipelines.where(status: 10).map {|e| transform_to_usd(e.total_fee, e.total_fee_currency)}.sum >= 10000000}
      }
    },
    # 用户为BD负责人：2，融资额大于1.5亿美金，上传el
    new_sign_growth_bd_goal_for_pe: { value: 3, desc: "asso/PE及以下成长期BD目标(新签)", unit: "个", is_system: true,
      op: -> (user_id) {
        Funding.includes(:funding_users).where(funding_users: {user_id: 1988, kind: 2}).select{|e| e if !e.file_el_attachment.nil? && e.pipelines.where(status: 10).map {|e| transform_to_usd(e.total_fee, e.total_fee_currency)}.sum >= 150000000}.count
      }
    },
    # 用户为BD负责人：2，融资额大于3亿美金，上传el
    new_sign_growth_bd_for_vp: {      value: 3, desc: "VP成长期BD目标(新签)", unit: "个", is_system: true,
      op: -> (user_id) {
        Funding.includes(:funding_users).where(funding_users: {user_id: 1988, kind: 2}).select{|e| e if !e.file_el_attachment.nil? && e.pipelines.where(status: 10).map {|e| transform_to_usd(e.total_fee, e.total_fee_currency)}.sum >= 300000000}.count
      }
    },
    # 用户为BD负责人：2，融资额大于5亿美金，上传el
    new_sign_growth_bd_for_director: {value: 3, desc: "Director成长期BD目标(新签)", unit: "个", is_system: true,
      op: -> (user_id) {
        Funding.includes(:funding_users).where(funding_users: {user_id: 1988, kind: 2}).select{|e| e if !e.file_el_attachment.nil? && e.pipelines.where(status: 10).map {|e| transform_to_usd(e.total_fee, e.total_fee_currency)}.sum >= 500000000}.count
      }
    },
    # 用户为BD负责人：2，融资额大于1.5亿美金，项目状态为paid：7，pipeline状态为已收款：10
    complete_growth_bd_for_pe: {      value: 3, desc: "asso/PE及以下成长期BD目标(完成)", unit: "个", is_system: true,
      op: -> (user_id) {
        Funding.includes(:funding_users).where(funding_users: {user_id: 1988, kind: 2}, status: 7).select{|e| e if e.pipelines.where(status: 10).map {|e| transform_to_usd(e.total_fee, e.total_fee_currency)}.sum >= 150000000}.count
      }
    },
    # 用户为BD负责人：2，融资额大于3亿美金，项目状态为paid：7，pipeline状态为已收款：10
    complete_growth_bd_for_vp: {      value: 3, desc: "VP成长期BD目标(完成)", unit: "个", is_system: true,
      op: -> (user_id) {
        Funding.includes(:funding_users).where(funding_users: {user_id: user_id, kind: 2}, status: 7).select{|e| e if e.pipelines.where(status: 10).map {|e| transform_to_usd(e.total_fee, e.total_fee_currency)}.sum >= 300000000}.count
      }
    },
    # 用户为BD负责人：2，融资额大于5亿美金，项目状态为paid：7，pipeline状态为已收款：10
    complete_growth_bd_for_director: { value: 3, desc: "Director成长期BD目标(完成)", unit: "个", is_system: true,
      op: -> (user_id) {
        Funding.includes(:funding_users).where(funding_users: {user_id: user_id, kind: 2}, status: 7).select{|e| e if e.pipelines.where(status: 10).map {|e| transform_to_usd(e.total_fee, e.total_fee_currency)}.sum >= 500000000}.count
      }
    },
    # 约见类型为公司：2，状态为完成：3
    visit_company: {                  value: 5, desc: "拜访公司", unit: "个", is_system: true,
      op: -> (user_id){
        Calendar.where(user_id: user_id, meeting_category: 2, status: 3).count
      }
    },
    # 约见类型为投资人：3，状态为完成：3，有ir_review
    visit_investor: {                 value: 6, desc: "拜访投资人", unit: "个", is_system: true,
      op: -> (user_id){
        Calendar.where(user_id: user_id, meeting_category: 3, status: 3).count
      }
    },
    # 覆盖的投资人 todolist 等覆盖投资人那块
    dept_coverage_investor: {         value: 7, desc: "投资人深度覆盖", unit: "个", is_system: true,
      op: -> (user_id){
        Member.where(user_id: user_id).count
      }
    },

    # alpha组
    # 用户为项目成员：1，状态为paid：7
    delivery_projects_number: {       value: 7, desc: "交割项目数量", unit: "个", is_system: true,
      op: -> (user_id){
        Funding.includes(:funding_users).where(funding_users: {user_id: user_id, kind: 1}, status: 7).count
      }
    },
    # 用户为项目成员：1，收入大于150万美元，状态为paid：7, pipeline状态为10
    income_from_delivery_projects: {  value: 8, desc: "交割项目收入", unit: "万", is_system: true,
      op: -> (user_id){
        Funding.includes(:funding_users).where(funding_users: {user_id: user_id, kind: 1}, status: 7).select{|e| e.pipelines.where(status: 10).map {|e| transform_to_usd(e.total_fee, e.total_fee_currency)}.sum >= 1500000}.count
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
    # 用户为项目成员：1，状态为paid：7
    project_execution: {              value: 12, desc: "项目执行", unit: "个", is_system: true,
      op: -> (user_id){
        Funding.includes(:funding_users).where(funding_users: {user_id: user_id, kind: 1}, status: 7).count
      }
    },
    # todolist等客户评价
    project_quality_scoring: {        value: 13, desc: "项目质量评分", unit: "分", is_system: true,
      op: ""
    },
    # 上传行业报告
    uploading_industry_reports: {     value: 14, desc: "上传行业报告", unit: "个", is_system: true,
      op: -> (user_id){
        ActiveStorage::Blob.where(user_id: user_id).map(&:attachments).flatten.count
      }
    },
    # 用户为执行负责人：3，状态为paid：7
    serving_as_project_po: {          value: 7, desc: "担任项目PO", unit: "个", is_system: true,
      op: -> (user_id){
        Funding.includes(:funding_users).where(funding_users: {user_id: user_id, kind: 3}, status: 7).count
      }
    },
    # 用户为项目成员：1，项目是否为复杂项目
    complex_projects: {               value: 7, desc: "复杂项目", unit: "个", is_system: true,
      op: -> (user_id, coverage){
        if coverage.nil?
          Funding.includes(:funding_users).where(funding_users: {user_id: user_id, kind: 2}, is_complicated: true).count
        else
          team = Team.find(coverage)
          teams = team.sub_teams
          teams.append(team).map(&:users).flatten.uniq.map {|user| Funding.includes(:funding_users).where(funding_users: {user_id: user_id, kind: 1}, is_complicated: true).count}.sum
        end
      }
    },

    # ka策略组
    # 用户为执行负责人：3，是否为ka
    execution_ka_project_po: {        value: 7, desc: "KA项目PO（执行）", unit: "个", is_system: true,
      op: -> (user_id){
        Funding.includes(:funding_users).where(funding_users: {user_id: user_id, kind: 3}, is_ka: true).count
      }
    },
    # 用户为执行负责人：3，是否为ka，状态为paid：7
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

    # 并购组
    # 用户为项目成员：1
    new_sign_ma_project: {            value: 7, desc: "新签并购项目", unit: "个", is_system: true,
      op: -> (user_id) {
        Funding.includes(:funding_users).where(funding_users: {user_id: user_id, kind: 1}).count
      }
    }
  }

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
