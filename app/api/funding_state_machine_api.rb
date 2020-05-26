class V2::FundingStateMachineApi < Grape::API
  resource :fundings, desc: '项目' do

    resource ':id' do
      before do
        @funding = Funding.find params[:id]
        authorize! :secret, @funding
      end

      after do
        # todo 所有状态修改全生成TimeLine
      end

      desc '进入Interesting阶段'
      params do
        optional :com_desc, type: String, desc: '公司简介'
        optional :products_and_business, type: String, desc: '产品与商业模式'
        optional :financial, type: String, desc: '财务数据'
        optional :operational, type: String, desc: '运营数据'
        optional :market_competition, type: String, desc: '市场竞争分析'
        # todo 确定BP的文件数量（阮丽楠）
        # todo 可能还有修改！
      end
      post 'interesting' do
        # todo 修改
      end

      desc '进入Voting阶段'
      params do
        requires :is_list, type: Boolean, desc: '是否为上市/新三板公司'
        optional :ticker, type: String, desc: '上市公司股票信息'
        requires :pre_investment_valuation, type: Float, desc: '本轮投前估值'
        requires :bd_leader_id, type: Integer, desc: 'BD负责人id'
        requires :execution_leader_id, type: Integer, desc: '执行负责人id'

        requires :com_desc, type: String, desc: '公司简介（不少于400字）'
        requires :products_and_business, type: String, desc: '产品与商业模式'
        requires :financial, type: String, desc: '财务数据'
        requires :operational, type: String, desc: '运营数据'
        requires :market_competition, type: String, desc: '市场竞争分析'
        # todo 可能还有修改！
      end
      post 'voting' do
        # todo 判断com_desc 400字
        # todo 修改
      end

      desc '进入Pursue阶段'
      params do

      end
      post 'pursue' do
        # todo 判断是不是管理员
        # todo 修改
      end

      desc '进入Execution阶段'
      params do

      end
      post 'execution' do
        # todo 判断是否上传了El
        # todo 判断是否填写了收入预测
        # todo 修改
      end

      desc '进入Closing阶段'
      params do

      end
      post 'closing' do
        # todo 判断是否上传了TS
        # todo 修改
      end

      desc '进入Closed阶段'
      params do

      end
      post 'closed' do
        # todo 判断是否上传了SPA
        # todo 判断是否完善了结算信息
        # todo 修改
      end

      desc '进入Paid阶段'
      params do

      end
      post 'paid' do
        # todo 判断是否完善了结算信息
        # todo 修改
      end

      desc '进入Hold阶段'
      params do

      end
      post 'hold' do
        # todo 修改
        # todo 填理由到TimeLine
      end

      desc '进入Pass阶段'
      params do
        optional :com_desc, type: String, desc: '公司简介'
        optional :products_and_business, type: String, desc: '产品与商业模式'
        optional :financial, type: String, desc: '财务数据'
        optional :operational, type: String, desc: '运营数据'
        optional :market_competition, type: String, desc: '市场竞争分析'
        optional :reason, type: String, desc: 'pass理由'
        # todo 确定BP的文件数量（阮丽楠）
        # todo 可能还有修改！
      end
      post 'pass' do
        # todo 修改
        # todo 填理由到TimeLine(除了 reviewing和interesting其他状态都必填)
      end
    end
  end
end
