class FundingApi < Grape::API
  helpers ::Helpers::FundingBigHelpers

  resource :fundings do
    desc '创建项目', entity: Entities::FundingComprehensive
    params do
      requires :categroy, type: Integer, desc: '项目类型'
      requires :company_id, type: Integer, desc: '公司id'
      requires :name, type: String, desc: '项目名称'

      optional :round_id, type: Integer, desc: '轮次'
      optional :target_amount_currency, type: Integer, desc: '交易金额币种'
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
      optional :source_type, type: Integer, desc: '融资来源类型'
      optional :source_member, type: Integer, desc: '投资者'
      optional :source_detail, type: String, desc: '来源明细'
      optional :funding_score, type: Integer, desc: '项目评分'

      optional :attachments, type: Array[File], desc: '附件'

      optional :project_user_ids, type: Array[Integer], desc: '项目成员id'
      optional :bd_leader_id, type: Integer, desc: 'BD负责人id'
      optional :execution_leader_id, type: Integer, desc: '执行负责人id'

      optional :teaser, type: File, desc: 'Teaser'
      optional :bp, type: File, desc: 'BP'
      optional :nda, type: File, desc: 'NDA'
      optional :model, type: File, desc: 'Model'
      optional :el, type: File, desc: 'EL'

      optional :funding_company_contacts, type: Array[JSON] do
        requires :name, type: String, desc: '成员名称'
        optional :position_id, type: Integer, desc: '职位（字典funding_contact_position）'
        optional :email, type: String, desc: '邮箱'
        optional :mobile, type: String, desc: '手机号码'
        optional :wechat, type: String, desc: '微信号'
        optional :is_attend, type: Boolean, desc: '是否参会'
        optional :is_open, type: Boolean, desc: '是否公开名片'
        optional :description, type: String, desc: '简介'
      end

      #todo 约见（5个字段的swagger）（李靖超）
    end
    post do
      auth_funding_code(params)
      Funding.transaction do
        funding = Funding.create(params.slice(:categroy, :company_id, :round_id, :target_amount_currency, :target_amount,
                                              :share, :shiny_word, :com_desc, :products_and_business, :financial,
                                              :operational, :market_competition, :financing_plan, :other_desc, :source_type,
                                              :source_member, :source_detail, :funding_score))
        funding.add_project_follower(params)
        funding.gen_funding_company_contacts(params)
        funding.funding_various_file(params)
        # todo 约见
      end
      present funding, with: Entities::FundingComprehensive
    end

    desc '项目列表', entity: Entities::FundingBaseInfo
    params do
      optional :keyword, type: String, desc: '关键字'
      optional :location_ids, type: Array[Integer], desc: '地点（字典locations）'
      optional :sector_ids, type: Array[Integer], desc: '行业（字典sector_tree）'
      optional :round_ids, type: Array[Integer], desc: '轮次(字典rounds)'
      optional :pipeline, type: Array[Integer], desc: 'Pipeline阶段'
      # todo Pipeline阶段暂时没有（李靖超）
    end
    get do
      fundings = Funding.es_search(params)
      present fundings, with: Entities::FundingBaseInfo
    end

    resource ':id' do
      before do
        @funding = Funding.find params[:id]
      end

      desc '编辑项目', entity: Entities::FundingComprehensive
      params do
        optional :categroy, type: Integer, desc: '项目类型'
        optional :name, type: String, desc: '项目名称'

        optional :round_id, type: Integer, desc: '轮次'
        optional :post_valuation_currency, type: Integer, desc: '本轮投后估值币种'
        optional :post_investment_valuation, type: Float, desc: '本轮投后估值'
        optional :target_amount_currency, type: Integer, desc: '交易金额币种'
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
        optional :source_type, type: Integer, desc: '融资来源类型'
        optional :source_member, type: Integer, desc: '投资者'
        optional :source_detail, type: String, desc: '来源明细'
        optional :funding_score, type: Integer, desc: '项目评分'

        optional :attachments, type: Array[File], desc: '附件'
        optional :attachment_ids, type: Array[Integer], desc: '附件id'

        optional :project_user_ids, type: Array[Integer], desc: '项目成员id'
        optional :bd_leader_id, type: Integer, desc: 'BD负责人id'
        optional :execution_leader_id, type: Integer, desc: '执行负责人id'

        optional :confidentiality_level, type: Integer, desc: '保密等级'
        optional :confidentiality_reason, type: String, desc: '保密原因'
        optional :is_reportable, type: Boolean, desc: '是否出现周日报'
        optional :is_complicated, type: Boolean, desc: '是否复杂项目'

        #todo 约见（5个字段的swagger）（李靖超）
      end
      patch do
        #todo 约见
        raise '咨询类型的项目不能修改类型' if @funding.categroy == Funding.categroy_advisory_value && @funding.categroy != params[:categroy]
        Funding.transaction do
          @funding.update(params.slice(:categroy, :name, :round_id, :shiny_word, :post_investment_valuation, :post_valuation_currency,
                                       :target_amount, :target_amount_currency, :share, :source_type, :source_member, :source_detail,
                                       :is_complicated, :funding_score, :confidentiality_level, :confidentiality_reason, :is_reportable,
                                       :com_desc, :products_and_business, :financial, :operational, :market_competition, :financing_plan,
                                       :other_desc))
          @funding.add_project_follower(params)
          @funding.funding_various_file(params)
        end
        present funding, with: Entities::FundingComprehensive
      end

      desc '项目详情', entity: Entities::FundingComprehensive
      params do
        requires :type, type: String, desc: '样式：弹窗：pop、页面：page、状态流转相关字段: status'
      end
      get do
        case params[:type]
        when 'pop'
          present @funding, with: Entities::Funding
        when 'page'
          present @funding, with: Entities::FundingComprehensive
        when 'status'
          present @funding, with: Entities::FundingStatus
        end
      end
    end
  end
end