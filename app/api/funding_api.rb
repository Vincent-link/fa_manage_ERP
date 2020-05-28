class FundingApi < Grape::API
  helpers ::Helpers::FundingBigHelpers

  resource :fundings do
    desc '创建项目', entity: Entities::FundingLite
    params do
      requires :category, type: Integer, desc: '项目类型'
      requires :company_id, type: Integer, desc: '公司id'
      requires :name, type: String, desc: '项目名称'

      optional :round_id, type: Integer, desc: '轮次'
      optional :currency_id, type: Integer, desc: '币种'
      optional :target_amount, type: Float, desc: '交易金额'
      optional :share, type: Float, desc: '出让股份'
      optional :shiny_word, type: String, desc: '一句话亮点'
      optional :com_desc, type: String, desc: '公司简介'
      optional :products_and_business, type: String, desc: '产品与商业模式'
      optional :financial, type: String, desc: '财务数据'
      optional :operational, type: String, desc: '运营数据'
      optional :market_competition, type: String, desc: '市场竞争分析'
      optional :financing_plan, type: String, desc: '融资计划'
      optional :other_desc, type: String, desc: '其他'
      optional :sources_type, type: Integer, desc: '融资来源类型'
      optional :sources_member, type: Integer, desc: '投资者'
      optional :sources_detail, type: String, desc: '来源明细'
      optional :funding_score, type: Integer, desc: '项目评分'

      optional :attachment, type: Array[File], desc: '附件'

      optional :project_user_ids, type: Array[Integer], desc: '项目成员id'
      optional :bd_leader_id, type: Integer, desc: 'BD负责人id'
      optional :execution_leader_id, type: Integer, desc: '执行负责人id'

      #todo 约见（5个字段的swagger）（李靖超）

      #todo 上传文档（暂时数量未定）（阮丽楠）
    end
    post do
      auth_funding_code(params)
      Funding.transaction do
        funding = Funding.create(params.slice(:category, :company_id, :round_id, :currency_id, :target_amount_min,
                                              :target_amount_max, :shares_min, :shares_max, :shiny_word, :com_desc,
                                              :products_and_business, :financial, :operational, :market_competition,
                                              :financing_plan, :other_desc, :sources_type, :sources_member, :sources_detail,
                                              :funding_score))
        funding.add_project_follower(params)
        # todo 上传附件（目前没有文档的表）
        # todo 约见
        # todo 上传文档（暂时数量未定）（阮丽楠）
      end
      present funding, with: Entities::FundingLite
    end

    desc '项目列表'
    params do
      optional :keyword, type: String, desc: '关键字'
      optional :address_id, type: Array[Integer], desc: '地点'
      optional :sector_id, type: Array[Integer], desc: '行业'
      optional :round_id, type: Array[Integer], desc: '轮次'
      optional :pipeline, type: Array[Integer], desc: 'Pipeline阶段'
      # todo Pipeline阶段暂时没有
    end
    get do

    end

    resource ':id' do
      before do
        @funding = Funding.find params[:id]
      end

      desc '编辑项目'
      params do
        optional :category, type: Integer, desc: '项目类型'
        optional :company_id, type: Integer, desc: '公司id'
        optional :name, type: String, desc: '项目名称'

        optional :round_id, type: Integer, desc: '轮次'
        optional :currency_id, type: Integer, desc: '币种'
        optional :target_amount, type: Float, desc: '交易金额'
        optional :share, type: Float, desc: '出让股份'
        optional :shiny_word, type: String, desc: '一句话亮点'
        optional :com_desc, type: String, desc: '公司简介'
        optional :products_and_business, type: String, desc: '产品与商业模式'
        optional :financial, type: String, desc: '财务数据'
        optional :operational, type: String, desc: '运营数据'
        optional :market_competition, type: String, desc: '市场竞争分析'
        optional :financing_plan, type: String, desc: '融资计划'
        optional :other_desc, type: String, desc: '其他'
        optional :sources_type, type: Integer, desc: '融资来源类型'
        optional :sources_member, type: Integer, desc: '投资者'
        optional :sources_detail, type: String, desc: '来源明细'
        optional :funding_score, type: Integer, desc: '项目评分'

        optional :attachment, type: Array[File], desc: '附件'

        optional :project_user_ids, type: Array[Integer], desc: '项目成员id'
        optional :bd_leader_id, type: Integer, desc: 'BD负责人id'
        optional :execution_leader_id, type: Integer, desc: '执行负责人id'

        #todo 约见（5个字段的swagger）（李靖超）

        #todo 上传文档（暂时数量未定）（阮丽楠）
      end
      patch do
        #todo 约见
        auth_funding_code(params)
        Funding.create(params.slice(:category))
      end

      desc '项目详情'
      params do

      end
      get do
        present @funding, with: Entities::Funding
      end
    end
  end
end