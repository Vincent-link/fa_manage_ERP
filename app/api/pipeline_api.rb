class PipelineApi < Grape::API
  resource :fundings do
    resource ':funding_id' do
      resource :pipelines do
        desc '获取pipeline', entity: Entities::Pipeline
        params do
          requires :funding_id, type: Integer, desc: '项目id'
        end
        get do
          funding = Funding.find params[:funding_id]
          present funding.pipelines, with: Entities::Pipeline
        end

        desc '新建pipeline'
        params do
          requires :funding_id, type: Integer, desc: '项目id'
          requires :status, type: Integer, desc: '项目所处阶段'
          optional :est_amount, type: Float, desc: '预计融资金额'
          #requires :est_amount_unit, type: Integer, desc: '预计融资金额单位'
          optional :est_amount_currency, type: Integer, desc: '融资金额币种'
          optional :fee_rate, type: Float, desc: '费率'
          optional :other_amount, type: Float, desc: '其他费用'
          optional :success_fee, type: Float, desc: '成功费'
          optional :complete_rate, type: Float, desc: '年内完成概率'
          optional :total_fee, type: Float, desc: '项目总收入预测'
          optional :total_fee_currency, type: Integer, desc: '收入币种'
          optional :currency_rate, type: Float, desc: '汇率'
          requires :el_date, type: Date, desc: '签约日期'
          requires :est_bill_date, type: Date, desc: '预计账单日期'
          optional :divide, type: Array[JSON], desc: '分成 [{user_id: 1, rate: 20}, {bu_id: 2, rate: 80}]'
        end
        post do
          pipeline = Pipeline.create! declared(params)
          present pipeline, with: Entities::Pipeline
        end
      end
    end
  end

  resource :pipelines do
    resource ':id' do
      desc '更新pipeline'
      params do
        requires :funding_id, type: Integer, desc: '项目id'
        requires :status, type: Integer, desc: '项目所处阶段'
        optional :est_amount, type: Float, desc: '预计融资金额'
        #requires :est_amount_unit, type: Integer, desc: '预计融资金额单位'
        optional :est_amount_currency, type: Integer, desc: '融资金额币种'
        optional :fee_rate, type: Float, desc: '费率'
        optional :other_amount, type: Float, desc: '其他费用'
        optional :success_fee, type: Float, desc: '成功费'
        optional :complete_rate, type: Float, desc: '年内完成概率'
        optional :total_fee, type: Float, desc: '项目总收入预测'
        optional :total_fee_currency, type: Integer, desc: '收入币种'
        optional :currency_rate, type: Float, desc: '汇率'
        requires :el_date, type: Date, desc: '签约日期'
        requires :est_bill_date, type: Date, desc: '预计账单日期'
        optional :divide, type: Array[JSON], desc: '分成 [{user_id: 1, rate: 20}, {bu_id: 2, rate: 80}]'
      end
      patch do
        pipeline = Pipeline.find params[:id]
        pipeline.update! declared(params)
        present pipeline, with: Entities::Pipeline
      end

      desc '删除pipeline'
      delete do
        pipeline = Pipeline.find params[:id]
        pipeline.destroy!
      end
    end

    desc 'Pipeline 列表', entity: Entities::PipelineList
    params do
      optional :is_me, type: Boolean, default: false, desc: '是否查询我的Pipeline'
      optional :funding_name, type: String, desc: '项目名称'
      optional :funding_status, type: Integer, desc: '项目状态'
      optional :status, type: Integer, desc: 'Pipeline阶段'
      optional :funding_category, type: Integer, desc: '产品 + 轮次(传入轮次时,is_round为true)'
      optional :is_round, type: Boolean, desc: 'funding_category传入轮次时: true'
      optional :team_id, type: Integer, desc: 'FA负责的小组(用户列表中的团队)'
      optional :sector_id, type: Integer, desc: '行业（字典sector_tree）'
      optional :is_list_company, type: Boolean, desc: '是否为上市公司'
      optional :est_amount_currency, type: Integer, desc: '币种'
      optional :funding_source, type: Integer, desc: '项目来源'
      optional :type, type: Integer, desc: '完成&执行总表 1/ 已完成 2/ Closing 3/ 无TS 4/ 终止项目 5'
      optional :year, type: Integer, desc: '搜索的年份'
      optional :month, type: Integer, desc: '搜索的月份'
      given is_me: ->(value) { value } do
        optional :page, type: Integer, desc: '页码', default: 1
        optional :per_page, type: Integer, desc: '数量', default: 10
      end

      optional :sort, type: Integer, desc: 'lastUpdatedDay 1 / elDate 2/ estBillDate 3/ executionDay 4/ totalFee 5/ buRate 6/ buTotalFee 7/ completeRate 8/ buRateIncome 9/ fundingOperatingDay 10'
      optional :by, type: Integer, desc: 'ASC 1/ DESC 2'
    end

    get do
      pipelines = Pipeline.es_search(params)[:results]
      page_info = Pipeline.es_search(params)[:page_info]

      if options[:type] == 5
        present pipelines, with: Entities::PipelineListForPass, page_info: page_info
      else
        present pipelines, with: Entities::PipelineList, page_info: page_info
      end
    end

    desc 'pipeline 导出'
    params do
      optional :is_me, type: Boolean, default: false, desc: '是否查询我的Pipeline'
      optional :funding_name, type: String, desc: '项目名称'
      optional :funding_status, type: Integer, desc: '项目状态'
      optional :status, type: Integer, desc: 'Pipeline阶段'
      optional :funding_category, type: Integer, desc: '产品 + 轮次(传入轮次时,is_round为true)'
      optional :is_round, type: Boolean, desc: 'funding_category传入轮次时: true'
      optional :team_id, type: Integer, desc: 'FA负责的小组(用户列表中的团队)'
      optional :sector_id, type: Integer, desc: '行业（字典sector_tree）'
      optional :is_list_company, type: Boolean, desc: '是否为上市公司'
      optional :est_amount_currency, type: Integer, desc: '币种'
      optional :funding_source, type: Integer, desc: '项目来源'
      optional :type, type: Integer, desc: '完成&执行总表 1/ 已完成 2/ Closing 3/ 无TS 4/ 终止项目 5/ FA项目收入贡献表 6'
      optional :year, type: Integer, desc: '搜索的年份'
      optional :month, type: Integer, desc: '搜索的月份'
      given is_me: ->(value) { value } do
        optional :page, type: Integer, desc: '页码', default: 1
        optional :per_page, type: Integer, desc: '数量', default: 10
      end

      optional :sort, type: Integer, desc: 'lastUpdatedDay 1 / elDate 2/ estBillDate 3/ executionDay 4/ totalFee 5/ buRate 6/ buTotalFee 7/ completeRate 8/ buRateIncome 9/ fundingOperatingDay 10'
      optional :by, type: Integer, desc: 'ASC 1/ DESC 2'
    end

    get :export do
      file_path, file_name = Pipeline.export(params)
      header['Content-Disposition'] = "attachment; filename=\"#{File.basename(file_name)}.xls\""
      content_type("application/octet-stream")
      env['api.format'] = :binary
      body File.read file_path
    end
  end

  mount HistoryApi, with: {owner: 'pipelines'}
end
