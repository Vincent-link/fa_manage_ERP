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
          optional :divide, type: Array[JSON], desc: '分成 [{user_id: 1, rate: 20}]'
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
        optional :divide, type: Array[JSON], desc: '分成 [{user_id: 1, rate: 20}]'
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
  end
  mount HistoryApi, with: {owner: 'pipelines'}
end