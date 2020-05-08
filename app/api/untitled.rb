class UsersListApi < Grape::API
  resource :users_lists do
    desc '用户列表', entity: Entities::OrganizationForIndex
    params do
      optional :query, type: String, desc: '检索文本'
      optional :sector, type: Array[Integer], desc: '行业', default: []
      optional :round, type: Array[Integer], desc: '轮次', default: []
      optional :amount_min, type: Integer, desc: '美元融资规模最小'
      optional :amount_max, type: Integer, desc: '美元融资规模最大'
      optional :level, type: Array[String], desc: '分级'
      optional :investor_group_id, type: Integer, desc: '投资人名单id'
      optional :currency, type: Array[Integer], desc: '币种', default: []
      requires :layout, type: String, desc: 'index/select', default: 'index'
      requires :page, type: Integer, desc: '页数', default: 1
      requires :per_page, type: Integer, desc: '每页条数', default: 30
    end
    get do
      organizations = Organization.es_search(params)
      case params[:layout]
      when 'index'
        present organizations, with: Entities::OrganizationForIndex
      when 'select'
        present organizations, with: Entities::OrganizationForSelect
      end
    end

    desc '检索公海机构', entity: Entities::DmOrganizationLite
    params do
      requires :query, type: String, desc: '检索' #todo validation length
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
      optional :tags, type: Array[Integer], desc: '机构标签'
      optional :sector_ids, type: Array[Integer], desc: '关注行业'
      optional :round_ids, type: Array[Integer], desc: '关注轮次'
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
      optional :logo, type: String, desc: '机构logo'
    end
    post do
      present Organization.create!(params), with: Entities::OrganizationForShow
    end

    desc '动态（假）'
    get :change_logs do

    end

    resources ':id' do
      before do
        @organization = Organization.find(params.delete(:id))
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

      desc '案例（假）'
      get :investment_event do
        []
      end

      desc '案例统计（假）'
      get :investment_stat do

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
        optional :tags, type: Array[Integer], desc: '机构标签'
        optional :sector_ids, type: Array[Integer], desc: '关注行业'
        optional :round_ids, type: Array[Integer], desc: '关注轮次'
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
        optional :logo, type: String, desc: '机构logo'
      end
      patch do
        present Organization.update!(params), with: Entities::OrganizationForShow
      end

      desc '跟进情况（假）'
      get :track_logs do

      end

      desc '未跟进项目（假）'
      get :untrack_funding do

      end

      desc 'portfollo（假）'
      get :portfollo do

      end
    end
  end

  mount CommentApi, with: {owner: 'organizations'}
  mount AddressApi, with: {owner: 'organizations'}
  mount HistoryApi, with: {owner: 'organizations'}
end