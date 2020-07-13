class FundingStateMachineApi < Grape::API
  helpers ::Helpers::FundingBigHelpers

  resource :fundings, desc: '项目' do

    resource ':id' do
      before do
        @funding = Funding.find params[:id]
      end

      after do
        @funding.update(operating_day: Date.today)
        @funding.time_lines.create(status: @funding.status, reason: params[:reason], user_id: current_user.id)
      end

      desc '进入Interesting阶段', entity: Entities::FundingLite
      params do
        optional :com_desc, type: String, desc: '公司简介'
        optional :products_and_business, type: String, desc: '产品与商业模式'
        optional :financial, type: String, desc: '财务数据'
        optional :operational, type: String, desc: '运营数据'
        optional :market_competition, type: String, desc: '市场竞争分析'
        optional :financing_plan, type: String, desc: '融资计划'
        optional :team_desc, type: String, desc: '团队介绍'
        optional :other_desc, type: String, desc: '其他'
        optional :file_bp, type: Hash do
          optional :blob_id, type: Integer, desc: 'BP文件blob_id'
          optional :id, type: Integer, desc: '新建里这个字段没用'
        end
      end
      post 'interesting' do
        @funding.funding_status_auth(Funding.status_reviewing_value, Funding.status_interesting_value, params)
        @funding.funding_various_file(params.slice(:file_bp))
        @funding.update(params.slice(:com_desc, :products_and_business, :financial, :operational, :market_competition,
                                     :financing_plan, :team_desc, :other_desc).merge(status: Funding.status_interesting_value))
        present @funding, with: Entities::FundingLite
      end

      desc '进入Voting阶段', entity: Entities::FundingLite
      params do
        requires :is_list, type: Boolean, desc: '是否为上市/新三板公司'
        optional :ticker, type: String, desc: '上市公司股票信息'
        requires :post_investment_valuation, type: Float, desc: '本轮投后估值'
        requires :post_valuation_currency, type: Integer, desc: '本轮投后估值币种'

        requires :com_desc, type: String, desc: '公司简介（不少于400字）'
        requires :products_and_business, type: String, desc: '产品与商业模式'
        requires :financial, type: String, desc: '财务数据'
        requires :operational, type: String, desc: '运营数据'
        requires :market_competition, type: String, desc: '市场竞争分析'
        requires :financing_plan, type: String, desc: '融资计划'
        optional :team_desc, type: String, desc: '团队介绍'
        optional :other_desc, type: String, desc: '其他'
      end
      post 'voting' do
        @funding.funding_status_auth(Funding.status_interesting_value, Funding.status_voting_value, params)
        @funding.update(params.slice(:com_desc, :products_and_business, :financial, :operational, :market_competition,
                                     :financing_plan, :team_desc, :other_desc, :is_list, :ticker, :post_investment_valuation,
                                     :currency_id).merge(status: Funding.status_voting_value))
        present @funding, with: Entities::FundingLite
      end

      desc '进入Pursue阶段', entity: Entities::FundingLite
      params do

      end
      post 'pursue' do
        raise '需要补充bd负责人、执行负责人信息' unless @funding.bd_leader.present? && @funding.execution_leader.present?
        @funding.funding_status_auth(Funding.status_voting_value, Funding.status_pursue_value, params)
        # todo 判断是不是管理员
        # todo 然后就没用了
        present @funding, with: Entities::FundingLite
      end

      desc '进入Execution阶段', entity: Entities::FundingLite
      params do

      end
      post 'execution' do
        @funding.funding_status_auth(Funding.status_pursue_value, Funding.status_execution_value, params)
        @funding.update(status: Funding.status_execution_value)
        present @funding, with: Entities::FundingLite
      end

      desc '进入Closing阶段', entity: Entities::FundingLite
      params do

      end
      post 'closing' do
        @funding.funding_status_auth(Funding.status_execution_value, Funding.status_closing_value, params)
        @funding.update(status: Funding.status_closing_value)
        present @funding, with: Entities::FundingLite
      end

      desc '进入Closed阶段', entity: Entities::FundingLite
      params do

      end
      post 'closed' do
        @funding.funding_status_auth(Funding.status_closing_value, Funding.status_closed_value, params)
        @funding.update(status: Funding.status_closed_value)
        present @funding, with: Entities::FundingLite
      end

      desc '进入Paid阶段', entity: Entities::FundingLite
      params do

      end
      post 'paid' do
        @funding.funding_status_auth(Funding.status_closed_value, Funding.status_paid_value, params)
        @funding.update(status: Funding.status_paid_value)
        present @funding, with: Entities::FundingLite
      end

      desc '进入Hold阶段', entity: Entities::FundingLite
      params do
        optional :reason, type: String, desc: 'hold理由'
      end
      post 'hold' do
        @funding.funding_status_auth(@funding.status, Funding.status_hold_value, params)
        @funding.update(params.slice(:reason).merger(status: Funding.status_hold_value))
        present @funding, with: Entities::FundingLite
      end

      desc '进入Pass阶段', entity: Entities::FundingLite
      params do
        optional :com_desc, type: String, desc: '公司简介'
        optional :products_and_business, type: String, desc: '产品与商业模式'
        optional :financial, type: String, desc: '财务数据'
        optional :operational, type: String, desc: '运营数据'
        optional :market_competition, type: String, desc: '市场竞争分析'
        optional :financing_plan, type: String, desc: '融资计划'
        optional :team_desc, type: String, desc: '团队介绍'
        optional :other_desc, type: String, desc: '其他'
        optional :reason, type: String, desc: 'pass理由'
        optional :file_bp, type: Hash do
          optional :blob_id, type: Integer, desc: 'BP文件blob_id'
          optional :id, type: Integer, desc: '新建里这个字段没用'
        end
      end
      post 'pass' do
        @funding.funding_status_auth(@funding.status, Funding.status_pass_value, params)
        @funding.funding_various_file(params.slice(:file_bp))
        @funding.update(params.slice(:com_desc, :products_and_business, :financial, :operational, :market_competition,
                                     :financing_plan, :team_desc, :other_desc, :reason).merge(status: Funding.status_pass_value))
        present @funding, with: Entities::FundingLite
      end

      desc '随便移动项目（管理员特权）', entity: Entities::FundingLite
      params do
        requires :status, type: Integer, desc: '状态'
      end
      patch 'status' do
        # todo 判断管理员权限
        if params[:status] == Funding.status_pursue_value
          @funding.update!(status: params[:status], agree_time: Time.now)
        else
          @funding.update!(status: params[:status])
        end
        present @funding, with: Entities::FundingLite
      end
    end
  end
end
