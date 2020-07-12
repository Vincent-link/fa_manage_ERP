class Kpi < ApplicationRecord
  belongs_to :kpi_group, optional: true
  has_many :conditions, class_name: "Kpi", foreign_key: :parent_id

  include StateConfig

  state_config :kpi_type, config: {
    # kind:2 bd负责人，上传el为新签，status:7为完成，新签和完成的项目需要满足融资额和收入条件, coverage：nil为个人，否则团队
    # 用户为BD负责人：2，收入大于40万或者融资额大于1000万，且上传el，新签是不需要判断pipeline状态的，完成需要
    new_sign_bd_goal: {               value: 1, desc: "BD总体目标（新签）", unit: "个", is_system: true, action: "新签", remarks: "新签或者完成一定数量的项目（重组前过会的项目，今年新签或者今年完成的项目，只有1000万美元融资额或40万美元收入以上的才会计入目标KR）",
      op: -> (user_id, coverage, year){
        if coverage.nil?
          Funding.includes(:funding_users).where(funding_users: {user_id: user_id, kind: FundingUser.kind_config[:bd_leader][:value]}).where("extract(year from fundings.created_at)  = ?", year).select{|e| !e.file_el_attachment.nil? && (e.pipelines.map {|e| transform_to_usd(e.total_fee, e.total_fee_currency)}.sum >= Settings.kpi.total_fee || e.pipelines.map {|e| transform_to_usd(e.est_amount, e.est_amount_currency)}.sum >= Settings.kpi.est_amount)}.count
        else
          team = Team.find(coverage)
          teams = team.sub_teams
          teams.append(team).map(&:users).flatten.uniq.map {|user| Funding.includes(:funding_users).where(funding_users: {user_id: user.id, kind: FundingUser.kind_config[:bd_leader][:value]}).where("extract(year from fundings.created_at)  = ?", year).select{|e| !e.file_el_attachment.nil? && (e.pipelines.map {|e| transform_to_usd(e.total_fee, e.total_fee_currency)}.sum >= Settings.kpi.total_fee || e.pipelines.map {|e| transform_to_usd(e.est_amount, e.est_amount_currency)}.sum >= Settings.kpi.est_amount)}.count}.sum
        end
      }
    },
    # 用户为BD负责人：2，收入大于40万或者融资额大于1000万，项目状态为paid：7，pipeline状态为已收款：10
    complete_bd_goal: {               value: 2, desc: "BD总体目标（完成）", unit: "个", is_system: true, action: "完成", remarks: "新签或者完成一定数量的项目（重组前过会的项目，今年新签或者今年完成的项目，只有1000万美元融资额或40万美元收入以上的才会计入目标KR）",
      op: -> (user_id, coverage, year){
        if coverage.nil?
          Funding.includes(:funding_users).where(funding_users: {user_id: user_id, kind: FundingUser.kind_config[:bd_leader][:value]}, status: Funding.status_config[:paid][:value]).where("extract(year from fundings.created_at)  = ?", year).select{|e| !e.file_el_attachment.nil? && (e.pipelines.where(status: Pipeline.status_config[:fee_ed][:value]).map {|e| transform_to_usd(e.total_fee, e.total_fee_currency)}.sum >= Settings.kpi.total_fee || e.pipelines.where(status: Pipeline.status_config[:fee_ed][:value]).map {|e| transform_to_usd(e.est_amount, e.est_amount_currency)}.sum >= Settings.kpi.est_amount)}.count
        else
          team = Team.find(coverage)
          teams = team.sub_teams
          teams.append(team).map(&:users).flatten.uniq.map {|user| Funding.includes(:funding_users).where(funding_users: {user_id: user_id, kind: FundingUser.kind_config[:bd_leader][:value]}, status: Funding.status_config[:paid][:value]).where("extract(year from fundings.created_at)  = ?", year).select{|e| !e.file_el_attachment.nil? && (e.pipelines.where(status: Pipeline.status_config[:fee_ed][:value]).map {|e| transform_to_usd(e.total_fee, e.total_fee_currency)}.sum >= Settings.kpi.total_fee || e.pipelines.where(status: Pipeline.status_config[:fee_ed][:value]).map {|e| transform_to_usd(e.est_amount, e.est_amount_currency)}.sum >= Settings.kpi.est_amount)}.count}.sum
        end
      }
    },


    # 用户为BD负责人：2，融资额大于1.5亿美金，上传el
    new_sign_growth_bd_goal_for_pe: { value: 3, desc: "asso/PE及以下成长期BD目标(新签)", unit: "个", is_system: true, action: "新签", remarks: "作为BD负责人，新签或者完成一定数量的项目",
      op: -> (user_id, coverage, year){
        if coverage.nil?
          Funding.includes(:funding_users).where(funding_users: {user_id: user_id, kind: FundingUser.kind_config[:bd_leader][:value]}).where("extract(year from fundings.created_at)  = ?", year).select{|e| !e.file_el_attachment.nil? && e.pipelines.map {|e| transform_to_usd(e.est_amount, e.est_amount_currency)}.sum >= Settings.kpi.growth_pe_est_amount}.count
        else
          team = Team.find(coverage)
          teams = team.sub_teams
          teams.append(team).map(&:users).flatten.uniq.map {|user| Funding.includes(:funding_users).where(funding_users: {user_id: user.id, kind: FundingUser.kind_config[:bd_leader][:value]}).where("extract(year from fundings.created_at)  = ?", year).select{|e| !e.file_el_attachment.nil? && e.pipelines.map {|e| transform_to_usd(e.est_amount, e.est_amount_currency)}.sum >= Settings.kpi.growth_pe_est_amount}.count}.sum
        end
      }
    },
    # 用户为BD负责人：2，融资额大于3亿美金，上传el
    new_sign_growth_bd_for_vp: {      value: 4, desc: "VP成长期BD目标(新签)", unit: "个", is_system: true, action: "新签", remarks: "作为BD负责人，新签或者完成一定数量的项目",
      op: -> (user_id, coverage, year){
        if coverage.nil?
          Funding.includes(:funding_users).where(funding_users: {user_id: user_id, kind: FundingUser.kind_config[:bd_leader][:value]}).where("extract(year from fundings.created_at)  = ?", year).select{|e| !e.file_el_attachment.nil? && e.pipelines.map {|e| transform_to_usd(e.est_amount, e.est_amount_currency)}.sum >= Settings.kpi.growth_vp_est_amount}.count
        else
          team = Team.find(coverage)
          teams = team.sub_teams
          teams.append(team).map(&:users).flatten.uniq.map {|user| Funding.includes(:funding_users).where(funding_users: {user_id: user.id, kind: FundingUser.kind_config[:bd_leader][:value]}).where("extract(year from fundings.created_at)  = ?", year).select{|e| !e.file_el_attachment.nil? && e.pipelines.map {|e| transform_to_usd(e.est_amount, e.est_amount_currency)}.sum >= Settings.kpi.growth_vp_est_amount}.count}.sum
        end
      }
    },
    # 用户为BD负责人：2，融资额大于5亿美金，上传el
    new_sign_growth_bd_for_director: {value: 5, desc: "Director成长期BD目标(新签)", unit: "个", is_system: true, action: "新签", remarks: "作为BD负责人，新签或者完成一定数量的项目",
      op: -> (user_id, coverage, year){
        if coverage.nil?
          Funding.includes(:funding_users).where(funding_users: {user_id: user_id, kind: FundingUser.kind_config[:bd_leader][:value]}).where("extract(year from fundings.created_at)  = ?", year).select{|e| !e.file_el_attachment.nil? && e.pipelines.map {|e| transform_to_usd(e.est_amount, e.est_amount_currency)}.sum >= Settings.kpi.growth_director_est_amount}.count
        else
          team = Team.find(coverage)
          teams = team.sub_teams
          teams.append(team).map(&:users).flatten.uniq.map {|user| Funding.includes(:funding_users).where(funding_users: {user_id: user.id, kind: FundingUser.kind_config[:bd_leader][:value]}).where("extract(year from fundings.created_at)  = ?", year).select{|e| !e.file_el_attachment.nil? && e.pipelines.map {|e| transform_to_usd(e.est_amount, e.est_amount_currency)}.sum >= Settings.kpi.growth_director_est_amount}.count}.sum
        end
      }
    },
    # 用户为BD负责人：2，融资额大于1.5亿美金，项目状态为paid：7，pipeline状态为已收款：10
    complete_growth_bd_for_pe: {      value: 6, desc: "asso/PE及以下成长期BD目标(完成)", unit: "个", is_system: true, action: "完成", remarks: "作为BD负责人，新签或者完成一定数量的项目",
      op: -> (user_id, coverage, year){
        if coverage.nil?
          Funding.includes(:funding_users).where(funding_users: {user_id: user_id, kind: FundingUser.kind_config[:bd_leader][:value]}, status: Funding.status_config[:paid][:value]).select{|e| e.pipelines.where(status: Pipeline.status_config[:fee_ed][:value]).map {|e| transform_to_usd(e.est_amount, e.est_amount_currency)}.sum >= Settings.kpi.growth_director_est_amount}.count
        else
          team = Team.find(coverage)
          teams = team.sub_teams
          teams.append(team).map(&:users).flatten.uniq.map {|user| Funding.includes(:funding_users).where(funding_users: {user_id: user.id, kind: FundingUser.kind_config[:bd_leader][:value]}, status: Funding.status_config[:paid][:value]).select{|e| e.pipelines.where(status: Pipeline.status_config[:fee_ed][:value]).map {|e| transform_to_usd(e.est_amount, e.est_amount_currency)}.sum >= Settings.kpi.growth_director_est_amount}.count}.sum
        end
      }
    },
    # 用户为BD负责人：2，融资额大于3亿美金，项目状态为paid：7，pipeline状态为已收款：10
    complete_growth_bd_for_vp: {      value: 7, desc: "VP成长期BD目标(完成)", unit: "个", is_system: true, action: "完成", remarks: "作为BD负责人，新签或者完成一定数量的项目",
      op: -> (user_id, coverage, year){
        if coverage.nil?
          Funding.includes(:funding_users).where(funding_users: {user_id: user_id, kind: FundingUser.kind_config[:bd_leader][:value]}, status: Funding.status_config[:paid][:value]).select{|e| e.pipelines.where(status: Pipeline.status_config[:fee_ed][:value]).map {|e| transform_to_usd(e.est_amount, e.est_amount_currency)}.sum >= Settings.kpi.growth_vp_est_amount}.count
        else
          team = Team.find(coverage)
          teams = team.sub_teams
          teams.append(team).map(&:users).flatten.uniq.map {|user| Funding.includes(:funding_users).where(funding_users: {user_id: user.id, kind: FundingUser.kind_config[:bd_leader][:value]}, status: Funding.status_config[:paid][:value]).select{|e| e.pipelines.where(status: Pipeline.status_config[:fee_ed][:value]).map {|e| transform_to_usd(e.est_amount, e.est_amount_currency)}.sum >= Settings.kpi.growth_vp_est_amount}.count}.sum
        end
      }
    },
    # 用户为BD负责人：2，融资额大于5亿美金，项目状态为paid：7，pipeline状态为已收款：10
    complete_growth_bd_for_director: { value: 8, desc: "Director成长期BD目标(完成)", unit: "个", is_system: true, action: "完成", remarks: "作为BD负责人，新签或者完成一定数量的项目",
      op: -> (user_id, coverage, year){
        if coverage.nil?
          Funding.includes(:funding_users).where(funding_users: {user_id: user_id, kind: FundingUser.kind_config[:bd_leader][:value]}, status: Funding.status_config[:paid][:value]).select{|e| e.pipelines.where(status: Pipeline.status_config[:fee_ed][:value]).map {|e| transform_to_usd(e.est_amount, e.est_amount_currency)}.sum >= Settings.kpi.growth_director_est_amount}.count
        else
          team = Team.find(coverage)
          teams = team.sub_teams
          teams.append(team).map(&:users).flatten.uniq.map {|user| Funding.includes(:funding_users).where(funding_users: {user_id: user.id, kind: FundingUser.kind_config[:bd_leader][:value]}, status: Funding.status_config[:paid][:value]).select{|e| e.pipelines.where(status: Pipeline.status_config[:fee_ed][:value]).map {|e| transform_to_usd(e.est_amount, e.est_amount_currency)}.sum >= Settings.kpi.growth_director_est_amount}.count}.sum
        end
      }
    },
    # 约见类型为公司：2，状态为完成：3
    visit_company: {                  value: 9, desc: "拜访公司", unit: "个", is_system: true, action: "", remarks: "拜访一定数量的公司，需要有详细的CallReport",
      op: -> (user_id, coverage, year){
        if coverage.nil?
          Calendar.where(user_id: user_id, meeting_category: Calendar.meeting_category_config[:com_meeting][:value], status: Calendar.status_config[:done][:value]).count
        else
          team = Team.find(coverage)
          teams = team.sub_teams
          teams.append(team).map(&:users).flatten.uniq.map {|user| Calendar.where(user_id: user.id, meeting_category: Calendar.meeting_category_config[:com_meeting][:value], status: Calendar.status_config[:done][:value]).count}.sum
        end
      }
    },
    # 约见类型为投资人：3，状态为完成：3，有ir_review
    visit_investor: {                 value: 10, desc: "拜访投资人", unit: "个", is_system: true, action: "", remarks: "拜访一定数量的投资人，需要有详细的IR Review",
      op: -> (user_id, coverage, year){
        if coverage.nil?
          Calendar.where(user_id: user_id, meeting_category: Calendar.meeting_category_config[:org_meeting][:value], status: Calendar.status_config[:done][:value]).count
        else
          team = Team.find(coverage)
          teams = team.sub_teams
          teams.append(team).map(&:users).flatten.uniq.map {|user| Calendar.where(user_id: user.id, meeting_category: Calendar.meeting_category_config[:org_meeting][:value], status: Calendar.status_config[:done][:value]).count}.sum
        end
      }
    },
    # 覆盖的投资人 todo等覆盖投资人那块
    dept_coverage_investor: {         value: 11, desc: "投资人深度覆盖", unit: "个", is_system: true,
      op: -> (user_id){
        Member.where(user_id: user_id).count
      }
    },

    # alpha组
    # 用户为项目成员：1，状态为paid：7
    delivery_projects_number: {       value: 12, desc: "交割项目数量", unit: "个", is_system: true, action: "", remarks: "完成一定数量的项目交割，或者达到一定金额的项目收入",
      op: -> (user_id, coverage, year){
        if coverage.nil?
          Funding.includes(:funding_users).where(funding_users: {user_id: user_id, kind: FundingUser.kind_config[:normal_users][:value]}, status: Funding.status_config[:paid][:value]).count
        else
          team = Team.find(coverage)
          teams = team.sub_teams
          teams.append(team).map(&:users).flatten.uniq.map {|user| Funding.includes(:funding_users).where(funding_users: {user_id: user_id, kind: FundingUser.kind_config[:normal_users][:value]}, status: Funding.status_config[:paid][:value]).count}.sum
        end
      }
    },

    # 用户为项目成员：1，上传el
    new_sign_project_income: {  value: 13, desc: "项目收入(新签)", unit: "万", is_system: true, action: "新签", remarks: "新签项目达到一定金额的收入（新签项目指已签署EL的项目）",
      op: -> (user_id, coverage, year){
        if coverage.nil?
          Funding.includes(:funding_users).where(funding_users: {user_id: user_id, kind: FundingUser.kind_config[:normal_users][:value]}).map{|e| e.pipelines.where(status: Pipeline.status_config[:fee_ed][:value]).map {|e| transform_to_usd(e.total_fee, e.total_fee_currency)}.sum if !e.file_el_attachment.nil?}.sum
        else
          team = Team.find(coverage)
          teams = team.sub_teams
          teams.append(team).map(&:users).flatten.uniq.map {|user| Funding.includes(:funding_users).where(funding_users: {user_id: user.id, kind: FundingUser.kind_config[:normal_users][:value]}).map{|e| e.pipelines.where(status: Pipeline.status_config[:fee_ed][:value]).map {|e| transform_to_usd(e.total_fee, e.total_fee_currency)}.sum if !e.file_el_attachment.nil?}.sum}.sum
        end
      }
    },

    # 用户为项目成员：1，状态为paid：7, pipeline状态为10
    complete_project_income: {  value: 14, desc: "项目收入(完成)", unit: "万", is_system: true, action: "完成", remarks: "完成项目达到一定金额的收入（完成项目指已经进入Paid阶段的项目）",
      op: -> (user_id, coverage, year){
        if coverage.nil?
          Funding.includes(:funding_users).where(funding_users: {user_id: user_id, kind: FundingUser.kind_config[:normal_users][:value]}, status: Funding.status_config[:paid][:value]).map{|e| e.pipelines.where(status: Pipeline.status_config[:fee_ed][:value]).map {|e| transform_to_usd(e.total_fee, e.total_fee_currency)}.sum}.sum
        else
          team = Team.find(coverage)
          teams = team.sub_teams
          teams.append(team).map(&:users).flatten.uniq.map {|user| Funding.includes(:funding_users).where(funding_users: {user_id: user.id, kind: FundingUser.kind_config[:normal_users][:value]}, status: Funding.status_config[:paid][:value]).map{|e| e.pipelines.where(status: Pipeline.status_config[:fee_ed][:value]).map {|e| transform_to_usd(e.total_fee, e.total_fee_currency)}.sum}.sum}.sum
        end
      }
    },
    completion_of_medical_projects: { value: 15, desc: "完成医疗项目(不在系统统计)", unit: "个", is_system: false, action: "", remarks: "全组2020年完成至少一个医疗项目的交割或者2个医疗项目的执行",
      op: ""
    },
    execution_of_medical_projects: {  value: 16, desc: "执行医疗项目(不在系统统计)", unit: "个", is_system: false, action: "", remarks: "全组2020年完成至少一个医疗项目的交割或者2个医疗项目的执行",
      op: ""
    },
    growth_projects: {                value: 17, desc: "成长期项目(不在系统统计)", unit: "个", is_system: false, action: "", remarks: "每个季度整理一份市场上比较热门的项目名单用于内部分享，通过本组的source推荐，或者BU的客户成长，协助成长期团队签下3个成长期项目",
      op: ""
    },

    # 执行组
    # 用户为项目成员：1，状态为paid：7
    project_execution: {              value: 18, desc: "项目执行", unit: "个", is_system: true, action: "", remarks: "参与一定数量的项目执行",
      op: -> (user_id, coverage, year){
        if coverage.nil?
          Funding.includes(:funding_users).where(funding_users: {user_id: user_id, kind: FundingUser.kind_config[:normal_users][:value]}, status: Funding.status_config[:paid][:value]).count
        else
          team = Team.find(coverage)
          teams = team.sub_teams
          teams.append(team).map(&:users).flatten.uniq.map {|user| Funding.includes(:funding_users).where(funding_users: {user_id: user.id, kind: FundingUser.kind_config[:normal_users][:value]}, status: Funding.status_config[:paid][:value]).count}.sum
        end
      }
    },
    # todo 等问卷调查（闫涛）
    project_quality_scoring: {        value: 19, desc: "项目质量评分", unit: "分", is_system: true, action: "", remarks: "项目质量评分指标不能低于某个分数",
      op: ""
    },
    # 上传行业报告
    uploading_industry_reports: {     value: 20, desc: "上传行业报告", unit: "个", is_system: true, action: "", remarks: "上传一定数量的研究报告",
      op: -> (user_id, coverage, year){
        if coverage.nil?
          ActiveStorage::Blob.where(user_id: user_id).map(&:attachments).flatten.count
        else
          team = Team.find(coverage)
          teams = team.sub_teams
          teams.append(team).map(&:users).flatten.uniq.map {|user| ActiveStorage::Blob.where(user_id: user.id).map(&:attachments).flatten.count}.sum
        end
      }
    },
    # 用户为执行负责人：3，状态为paid：7
    serving_as_project_po: {          value: 21, desc: "担任项目PO", unit: "个", is_system: true, action: "", remarks: "担任一定数量的项目PO",
      op: -> (user_id, coverage, year){
        if coverage.nil?
          Funding.includes(:funding_users).where(funding_users: {user_id: user_id, kind: FundingUser.kind_config[:execution_leader][:value]}, status: Funding.status_config[:paid][:value]).count
        else
          team = Team.find(coverage)
          teams = team.sub_teams
          teams.append(team).map(&:users).flatten.uniq.map {|user| Funding.includes(:funding_users).where(funding_users: {user_id: user.id, kind: FundingUser.kind_config[:execution_leader][:value]}, status: Funding.status_config[:paid][:value]).count}.sum
        end
      }
    },
    # 用户为项目成员：1，项目是否为复杂项目
    complex_projects: {               value: 22, desc: "复杂项目", unit: "个", is_system: true, action: "", remarks: "参与一定数量的复杂项目",
      op: -> (user_id, coverage, year){
        if coverage.nil?
          Funding.includes(:funding_users).where(funding_users: {user_id: user_id, kind: FundingUser.kind_config[:normal_users][:value]}, is_complicated: true).count
        else
          team = Team.find(coverage)
          teams = team.sub_teams
          teams.append(team).map(&:users).flatten.uniq.map {|user| Funding.includes(:funding_users).where(funding_users: {user_id: user.id, kind: FundingUser.kind_config[:normal_users][:value]}, is_complicated: true).count}.sum
        end
      }
    },

    # 用户为项目成员：1，项目是否为复杂项目
    team_complex_projects: {               value: 23, desc: "复杂项目（全组）", unit: "个", is_system: true, action: "", remarks: "全组参与一定数量的复杂项目",
      op: -> (user_id, coverage, year){
        team = User.find(user_id).team
        teams = team.sub_teams
        teams.append(team).map(&:users).flatten.uniq.map {|user| Funding.includes(:funding_users).where(funding_users: {user_id: user.id, kind: FundingUser.kind_config[:normal_users][:value]}, is_complicated: true).count}.sum
      }
    },

    # ka策略组
    # 用户为执行负责人：3，是否为ka
    execution_ka_project_po: {        value: 24, desc: "KA项目PO（执行）", unit: "个", is_system: true, action: "执行", remarks: "作为项目PO执行或者完成一定数量的项目（必须为KA项目或者估值达到3亿美元）",
      op: -> (user_id, coverage, year){
        if coverage.nil?
          Funding.includes(:funding_users).where(funding_users: {user_id: user_id, kind: FundingUser.kind_config[:execution_leader][:value]}).select{|e| e.is_ka || e.post_investment_valuation >= Settings.kpi.post_investment_valuation}.count
        else
          team = Team.find(coverage)
          teams = team.sub_teams
          teams.append(team).map(&:users).flatten.uniq.map {|user| Funding.includes(:funding_users).where(funding_users: {user_id: user.id, kind: FundingUser.kind_config[:execution_leader][:value]}).select{|e| e.is_ka || e.post_investment_valuation >= Settings.kpi.post_investment_valuation}.count}.sum
        end
      }
    },
    # 用户为执行负责人：3，是否为ka，状态为paid：7
    complete_ka_project_po: {         value: 25, desc: "KA项目PO（完成）", unit: "个", is_system: true, action: "完成", remarks: "作为项目PO执行或者完成一定数量的项目（必须为KA项目或者估值达到3亿美元）",
      op: -> (user_id, coverage, year){
        if coverage.nil?
          Funding.includes(:funding_users).where(funding_users: {user_id: user_id, kind: FundingUser.kind_config[:execution_leader][:value]}, status: Funding.status_config[:paid][:value]).select{|e| e.is_ka || e.post_investment_valuation >= Settings.kpi.post_investment_valuation}.count
        else
          team = Team.find(coverage)
          teams = team.sub_teams
          teams.append(team).map(&:users).flatten.uniq.map {|user| Funding.includes(:funding_users).where(funding_users: {user_id: user.id, kind: FundingUser.kind_config[:execution_leader][:value], status: Funding.status_config[:paid][:value]}).select{|e| e.is_ka || e.post_investment_valuation >= Settings.kpi.post_investment_valuation}.count}.sum
        end
      }
    },
    depth_communicate_of_organ: {     value: 26, desc: "机构深度沟通（不在系统统计）", unit: "个", is_system: false, action: "", remarks: "与不少于10家成长期投资机构KOL完成深度沟通",
      op: ""
    },
    project_recommendation: {         value: 27, desc: "项目推荐（不在系统统计）", unit: "个", is_system: false, action: "", remarks: "从成长期投资机构KOL获得至少6个项目推荐",
      op: ""
    },

    # 并购组
    # 用户为项目成员：1
    new_sign_ma_project: {            value: 28, desc: "新签并购项目", unit: "个", is_system: true, action: "", remarks: "新签并购项目2个，含和其他组合作",
      op: -> (user_id, coverage, year){
        if coverage.nil?
          Funding.includes(:funding_users).where(funding_users: {user_id: user_id, kind: FundingUser.kind_config[:normal_users][:value]}).count
        else
          team = Team.find(coverage)
          teams = team.sub_teams
          teams.append(team).map(&:users).flatten.uniq.map {|user| Funding.includes(:funding_users).where(funding_users: {user_id: user.id, kind: FundingUser.kind_config[:normal_users][:value]}).count}.sum
        end
      }
    }
  }

  # 换算美元
  def self.transform_to_usd(total_fee, total_fee_currency)
    if !total_fee.nil?
      case total_fee_currency
      when 1
        total_fee/ConfigBox.rmb_usd_rate
      when 3
        total_fee
      end
    end
  end

  # 我的kpi
  def statis_my_kpi(user_id, year)
    Kpi.kpi_type_op_for_value(self.kpi_type).call(user_id, self.coverage, year)
  end

  # 我的kpi
  def is_in_system
    Kpi.kpi_type_config_for_value(self.kpi_type)[:is_system]
  end
end
