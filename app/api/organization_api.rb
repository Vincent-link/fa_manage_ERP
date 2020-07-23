class OrganizationApi < Grape::API
  resource :organizations do
    desc '投资机构列表', entity: Entities::OrganizationForIndex
    params do
      optional :query, type: String, desc: '检索文本', default: '*', coerce_with: ->(val) {val.present? ? val : '*'}
      optional :name, type: String, desc: '检索名称'
      optional :sector, type: Array[Integer], desc: '行业', default: []
      optional :round, type: Array[Integer], desc: '轮次', default: []
      optional :any_round, type: Boolean, desc: '是否不限轮次', default: false
      optional :amount_min, type: Integer, desc: '美元融资规模最小'
      optional :amount_max, type: Integer, desc: '美元融资规模最大'
      optional :level, type: Array[String], desc: '分级'
      optional :investor_group_id, type: Integer, desc: '投资人名单id'
      optional :tier, type: Array[Integer], desc: 'tier'
      optional :currency, type: Array[Integer], desc: '币种', default: []
      requires :layout, type: String, desc: 'index/select', default: 'index', values: ['index', 'select', 'ecm_group']
      requires :page, type: Integer, desc: '页数', default: 1
      optional :page_size, as: :per_page, type: Integer, desc: '每页条数', default: 30
      optional :per_page, type: Integer, desc: '每页条数', default: 30
      optional :order_by, type: String, values: ['level', 'last_investevent_date'], desc: '排序字段'
      optional :order_type, type: String, values: ['asc', 'desc'], desc: '排序类型', default: 'desc'
    end
    get do
      organizations = Organization.es_search(params)
      case params[:layout]
      when 'index'
        present organizations, with: Entities::OrganizationForIndex
      when 'select'
        present organizations, with: Entities::OrganizationForSelect
      when 'ecm_group'
        present organizations, with: Entities::OrganizationForEcmGroup, ecm_group: EcmGroup.find(params[:investor_group_id])
      end
    end

    desc '检索公海机构', entity: Entities::DmOrganizationLite
    params do
      requires :query, type: String, desc: '检索', regexp: /..+/
    end
    get :dm_search do
      dm_orgs = Zombie::DmInvestor.search_by_query_assist(params[:query])._select(:id, :name).limit(10).inspect
      org_hash = Organization.where(id: dm_orgs.map(&:id)).index_by(&:id)

      present dm_orgs, with: Entities::DmOrganizationLite, org_hash: org_hash
    end

    desc '创建机构', entity: Entities::OrganizationForShow
    params do
      optional :id, type: Integer, desc: '公海机构id'
      optional :name, type: String, desc: '机构名称'
      optional :en_name, type: String, desc: '机构英文名称'
      optional :level, type: String, desc: '级别，见公共字典值level'
      optional :site, type: String, desc: '机构官网'
      optional :organization_tag_ids, type: Array[Integer], desc: '机构标签'
      optional :sector_ids, type: Array[Integer], desc: '关注行业'
      optional :round_ids, type: Array[Integer], desc: '关注轮次'
      optional :any_round, type: Boolean, desc: '是否不限轮次', default: false
      optional :currency_ids, type: Array[Integer], desc: '可投币种'
      optional :aum, type: String, desc: '资产管理规模'
      optional :collect_info, type: String, desc: '募资情况'
      optional :stock_info, type: String, desc: '剩余可投金额'
      optional :rmb_amount_min, type: String, desc: '人民币最小金额'
      optional :rmb_amount_max, type: String, desc: '人民币最大金额'
      optional :usd_amount_min, type: String, desc: '美元最小金额'
      optional :usd_amount_max, type: String, desc: '美元最大金额'
      optional :followed_location_ids, type: Array[Integer], desc: '关注地区'
      optional :intro, type: String, desc: '机构简介'
      optional :logo_file, type: Hash, desc: '机构logo' do
        optional :id, type: Integer, desc: 'file_id 已有文件id'
        optional :blob_id, type: Integer, desc: 'blob_id 新文件id'
      end
      optional :invest_period, type: Integer, desc: '投资周期'
      optional :decision_flow, type: String, desc: '投资决策流程'
      optional :ic_rule, type: String, desc: '投委会机制'
      optional :alias, type: Array[String], desc: '机构别名'
      optional :addresses, type: Array[JSON], desc: '机构地址'
    end
    post do
      Organization.transaction do
        organization_tag_ids = params.delete(:organization_tag_ids)
        sector_ids = params.delete(:sector_ids)
        addresses = params.delete(:addresses)

        @organization = Organization.create!(declared(params, include_missing: false))

        addresses.each do |address|
          Zombie::DmAddress.create_address('Investor', @organization.id, nil, address[:location_id], address[:address_desc])
        end

        @organization.organization_tag_ids = organization_tag_ids
        @organization.sector_ids = sector_ids
      end
      present @organization, with: Entities::OrganizationForShow
    end

    desc '动态（假）'
    get :change_logs do

    end

    resources ':id' do
      before do
        @organization = Organization.find(params[:id])
      end

      desc '机构详情', entity: Entities::OrganizationForShow
      get do
        present @organization, with: Entities::OrganizationForShow
      end

      desc '新闻（假）'
      get :news do
        #todo news
        [{
             id: 1,
             title: 'helloworld',
             url: 'http://baidu.com',
             created_at: '2020-04-01',
             news_source: '公众号'
         }]
      end

      desc '职级关系', entity: Entities::DmMemberReportRelation
      get :member_relations do
        relations = Zombie::DmMemberReportRelation.includes(:member).where(members: {investor_id: params[:id]}).inspect
        present relations, with: Entities::DmMemberReportRelation
      end

      desc 'kick机构'
      delete do
        @organization.destroy!
      end

      desc '更新机构', entity: Entities::OrganizationForShow
      params do
        optional :id, type: Integer, desc: '公海机构id'
        optional :name, type: String, desc: '机构名称'
        optional :en_name, type: String, desc: '机构英文名称'
        optional :level, type: String, desc: '级别，见公共字典值level'
        optional :site, type: String, desc: '机构官网'
        optional :organization_tag_ids, type: Array[Integer], desc: '机构标签'
        optional :sector_ids, type: Array[Integer], desc: '关注行业'
        optional :round_ids, type: Array[Integer], desc: '关注轮次'
        optional :any_round, type: Boolean, desc: '是否不限轮次', default: false
        optional :currency_ids, type: Array[Integer], desc: '可投币种'
        optional :aum, type: String, desc: '资产管理规模'
        optional :collect_info, type: String, desc: '募资情况'
        optional :stock_info, type: String, desc: '剩余可投金额'
        optional :rmb_amount_min, type: String, desc: '人民币最小金额'
        optional :rmb_amount_max, type: String, desc: '人民币最大金额'
        optional :usd_amount_min, type: String, desc: '美元最小金额'
        optional :usd_amount_max, type: String, desc: '美元最大金额'
        optional :followed_location_ids, type: Array[Integer], desc: '关注地区'
        optional :intro, type: String, desc: '机构简介'
        optional :logo_file, type: Hash, desc: '机构logo' do
          optional :id, type: Integer, desc: 'file_id 已有文件id'
          optional :blob_id, type: Integer, desc: 'blob_id 新文件id'
        end
        requires :part, type: String, desc: '更新区域', values: ['basic', 'head', 'logo']

        optional :invest_period, type: Integer, desc: '投资周期'
        optional :decision_flow, type: String, desc: '投资决策流程'
        optional :ic_rule, type: String, desc: '投委会机制'
        optional :alias, type: Array[String], desc: '机构别名'
      end
      patch do
        part = params.delete(:part)
        case part
        when 'head'
          raise "中文名称不能为空" if params[:name].nil?
          raise "level不能为空" if params[:level].nil?
        when 'basic'
          raise "行业不能为空" if params[:sector_ids].nil?
          raise "轮次不能为空" if params[:round_ids].nil?
          raise "投资币种不能为空" if params[:currency_ids].nil?
        when 'logo'

        end

        @organization.organization_tag_ids = params[:organization_tag_ids]
        @organization.sector_ids = params[:sector_ids]
        params.delete(:organization_tag_ids)
        params.delete(:sector_ids)

        @organization.update!(declared(params, include_missing: false))
        present @organization, with: Entities::OrganizationForShow
      end


      desc '更新机构关系', entity: Entities::OrganizationForShow
      params do
        requires :relation_type, type: Integer, desc: '关系类型 1:上级 2:同级', values: [1, 2]
        requires :relation_organization_ids, type: Array[Integer], desc: '机构ids'
      end
      patch :organization_relations do
        @organization.organization_relations.where(relation_type: params[:relation_type]).where.not(relation_organization_id: params[:relation_organization_ids]).destroy_all
        params[:relation_organization_ids].each do |org_id|
          @organization.organization_relations.find_or_create_by! relation_type: params[:relation_type], relation_organization_id: org_id
        end
        present @organization, with: Entities::OrganizationForShow
      end

      desc '跟进情况'
      params do
        requires :page, type: Integer, desc: '页数', default: 1
        requires :page_size, as: :per_page, type: Integer, desc: '每页条数', default: 10
        optional :sector_ids, type: Array[Integer], desc: '行业'
        optional :round_ids, type: Array[Integer], desc: '轮次'
        optional :status, type: Array[Integer], desc: '状态'
      end
      get :track_logs do
        track_logs = @organization.track_logs.order(updated_at: :desc)
        if params[:sector_ids].present?
          track_logs = track_logs.includes(funding: :company)
        elsif params[:round_ids].present? || params[:status].present?
          track_logs = track_logs.includes(:funding)
        end
        track_logs = track_logs.where(fundings: {status: params[:status]}) if params[:status].present?
        track_logs = track_logs.where(fundings: {round_id: params[:round_ids]}) if params[:round_ids].present?
        track_logs = track_logs.where(fundings: {companies: {sector_id: params[:sector_ids]}}) if params[:sector_ids].present?

        present track_logs.paginate(page: params[:page], per_page: params[:per_page]), with: Entities::TrackLogForInteract
      end

      desc '未跟进项目'
      params do
        requires :page, type: Integer, desc: '页数', default: 1
        requires :page_size, as: :per_page, type: Integer, desc: '每页条数', default: 10
        optional :sector_ids, type: Array[Integer], desc: '行业'
        optional :round_ids, type: Array[Integer], desc: '轮次'
        optional :status, type: Array[Integer], desc: '状态'
      end
      get :untrack_funding do
        fundings = Funding.left_joins(:track_logs).where("track_logs.organization_id != #{@organization.id} or track_logs.organization_id is null").where(status: [Funding.status_pursue_value, Funding.status_execution_value, Funding.status_closing_value])
        fundings = fundings.where(status: params[:status]) if params[:status].present?
        fundings = fundings.where(round_id: params[:round_ids]) if params[:round_ids].present?
        fundings = fundings.includes(:company).where(companies: {sector_id: params[:sector_ids]}) if params[:sector_ids].present?
        present fundings.paginate(page: params[:page], per_page: params[:per_page]), with: Entities::FundingForUntrack, members: @organization.members
      end

      desc 'portfollo'
      params do
        requires :page, type: Integer, desc: '页数', default: 1
        requires :page_size, as: :per_page, type: Integer, desc: '每页条数', default: 10
      end
      get :portfollo do
        funding_ids, company_ids = Funding.includes(:track_logs).where(track_logs: {status: TrackLog.status_spa_sha, organization_id: @organization.id}).pluck(:id, :company_id).transpose
        present Funding.where(company_id: company_ids, status: [Funding.status_pursue_value, Funding.status_execution_value, Funding.status_closing_value]).where.not(id: funding_ids).paginate(page: params[:page], per_page: params[:per_page]), with: Entities::FundingForUntrack, members: @organization.members
      end
    end
  end

  mount CommentApi, with: {owner: 'organizations'}
  mount AddressApi, with: {owner: 'organizations'}
  mount HistoryApi, with: {owner: 'organizations'}
  mount InvesteventApi, with: {owner: 'organizations'}
  mount OrganizationTeamApi
end
