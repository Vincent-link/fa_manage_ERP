class FundingApi < Grape::API
  helpers ::Helpers::FundingBigHelpers

  resource :fundings do
    desc '创建项目'
    params do
      requires :category, type: Integer, desc: '项目类型'
      requires :company_id, type: Integer, desc: '公司id'

      optional :round_id, type: Integer, desc: '轮次'
      optional :currency_id, type: Integer, desc: '币种'
      optional :target_amount_min, type: Float, desc: '交易金额下限'
      optional :target_amount_max, type: Float, desc: '交易金额上限'
      optional :shares_min, type: Float, desc: '出让股份下限'
      optional :shares_max, type: Float, desc: '出让股份上限'
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
      # todo 上传附件（目前没有文档的表）
      # todo 约见
      # todo auth_funding_code(params)

      Funding.create(params.slice(:category, :company_id, :round_id, :currency_id))
    end

    desc '项目列表'
    params do

    end
    get do

    end
    resource ':id' do
      before do
        @funding = Funding.find params[:id]
      end

      desc '编辑项目'
      params do
        requires :category, type: Integer, desc: '项目类型'
        requires :company_id, type: Integer, desc: '公司id'

        optional :round_id, type: Integer, desc: '轮次'
        optional :currency_id, type: Integer, desc: '币种'
        optional :target_amount_min, type: Float, desc: '交易金额下限'
        optional :target_amount_max, type: Float, desc: '交易金额上限'
        optional :shares_min, type: Float, desc: '出让股份下限'
        optional :shares_max, type: Float, desc: '出让股份上限'
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

      end
    end
  end
end