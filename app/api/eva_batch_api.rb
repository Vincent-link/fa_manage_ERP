class EvaBatchApi < Grape::API
  helpers do
    def batch_now
      if Date.today.month < 7
        "#{Date.today.year}年年中互评"
      else
        "#{Date.today.year}年年末互评"
      end
    end
  end

  resource :eva_batchs do
    desc '获取批次', entity: Entities::QuestionnaireEvaBatchLite
    params do
      optional :started_at, type: Date, desc: '开始时间, 默认今年开始'
      optional :ended_at, type: Date, desc: '结束时间, 默认今年结束'
    end

    get 'batch_list' do
      year = Date.today.year
      params[:started_at] ||= Date.new(year)
      params[:ended_at] ||= Date.new(year, 12, 31)
      eva_batchs = Zombie::QsEvaBatch.search_eva_batch(params.slice(:started_at, :ended_at))._select(:id, :batch_name).inspect
      present eva_batchs, with: Entities::QuestionnaireEvaBatchLite
    end

    desc '获取当前互评批次', entity: Entities::QuestionnaireEvaBatchLite
    params do
    end

    get 'batch_now' do
      eva_batch = Zombie::QsEvaBatch.search_eva_batch(batch_name: batch_now).first
      unless eva_batch.present?
        eva_batch = Zombie::QsEvaBatch.create_or_update_eva_batch(batch_name: batch_now, template_id: 1002)
      end
      present eva_batch, with: Entities::QuestionnaireEvaBatchLite
    end

    desc '获取全部互评', entity: Entities::QuestionnaireBatchFundingWithEvaluation
    params do
      optional :eva_batch_id, type: Integer, desc: '互评批次'
      optional :batch_funding_status, type: Integer, desc: '互评状态'
      optional :funding_name, type: String, desc: '项目名称'
    end

    get 'all_evaluations' do
      params[:eva_batch_ids] = [params[:eva_batch_id]] if params[:eva_batch_ids].present?
      params[:funding_ids] = Funding.where('name ilike (?)', "%#{params[:funding_name]}%").map(&:id) if params[:funding_name].present?
      template = Zombie::QsTemplate.find 1002
      batch_funding_with_evaluations = template.all_batch_funding_with_evaluation(params.slice(:eva_batch_ids, :batch_funding_status, :funding_ids))
      present batch_funding_with_evaluations, with: Entities::QuestionnaireBatchFundingWithEvaluation
    end

    desc '获取我的互评', entity: Entities::QuestionnaireEvaluation
    params do
      optional :eva_batch_id, type: Integer, desc: '互评批次'
      optional :commit_status, type: Boolean, desc: '提交状态'
      optional :batch_funding_status, type: Integer, desc: '互评状态'
      optional :funding_name, type: String, desc: '项目名称'
    end

    get 'my_evaluations' do
      params[:eva_batch_ids] = [params[:eva_batch_id]] if params[:eva_batch_ids].present?
      params[:funding_ids] = Funding.where('name ilike (?)', "%#{params[:funding_name]}%").map(&:id) if params[:funding_name].present?
      template = Zombie::QsTemplate.find 1002
      evalutaions = template.my_evaluation(params.slice(:eva_batch_ids, :commit_status, :batch_funding_status, :funding_ids))
      present evalutaions, with: Entities::QuestionnaireEvaluation
    end

    resource ':id' do
      before do
        @eva_batch = Zombie::QsEvaBatch.system_find params[:id]
      end

      desc '获取待互评项目', entity: Entities::FundingLittleInfo
      params do
      end

      get 'not_batch_fundings' do
        batch_funding_ids = @eva_batch.batch_fundings_with_status([nil, 1]).map(&:id)
        fundings = Funding.where(status: FundingPolymer.status_filter(:pursue, :execution, :closing)).where.not(id: batch_funding_ids)
        present fundings, with: Entities::FundingLittleInfo
      end

      desc '获取已有互评项目', entity: Entities::FundingLittleInfo
      params do
      end

      get 'already_batch_fundings' do
        batch_funding_ids = @eva_batch.batch_fundings_with_status([nil]).map(&:funding_id)
        fundings = Funding.where(id: batch_funding_ids)
        present fundings, with: Entities::FundingLittleInfo
      end

      desc '启动互评', entity: Entities::QuestionnaireEvaBatchLite
      params do
        requires :funding_ids, type: Array[Integer], desc: '项目id'
      end

      post 'batch_fundings' do
        funding_ids = Funding.where(id: params[:funding_ids]).map(&:id)
        @eva_batch.pushing_batch_fundings(funding_ids)
        present @eva_batch, with: Entities::QuestionnaireEvaBatchLite
      end

      desc '关闭互评', entity: Entities::QuestionnaireEvaBatchLite
      params do
        optional :batch_funding_id, type: Integer, desc: '全部互评列表的batch_funding_id，不传就是整批关'
      end

      post 'close' do
        @eva_batch.close_eva_batch(params.slice(:batch_funding_id))
        present @eva_batch, with: Entities::QuestionnaireEvaBatchLite
      end

      desc '取消互评', entity: Entities::QuestionnaireEvaBatchLite
      params do
        optional :batch_funding_id, type: Integer, desc: '全部互评列表的batch_funding_id，不传就是整批关'
      end

      post 'cancel' do
        @eva_batch.cancel_eva_batch(params.slice(:batch_funding_id))
        present @eva_batch, with: Entities::QuestionnaireEvaBatchLite
      end
    end
  end
end