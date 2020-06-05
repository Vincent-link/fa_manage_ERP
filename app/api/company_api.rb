class CompanyApi < Grape::API
  resource :companies do
    desc '获取所有公司'
    params do
      optional :query, type: String, desc: '检索文本', default: '*'
      optional :sector_ids, type: Array[Integer], desc: '行业'
      optional :is_ka, type: Boolean, desc: 'KA'
      optional :recent_financing, type: String, desc: '最近融资'
      requires :page, type: Integer, desc: '页数', default: 1
      optional :page_size, as: :per_page, type: Integer, desc: '每页条数', default: 30
      optional :per_page, type: Integer, desc: '每页条数', default: 30
      optional :order_by, type: String, values: ['level', 'last_investevent_date'], desc: '排序字段'
      optional :order_type, type: String, values: ['asc', 'desc'], desc: '排序类型', default: 'desc'
    end
    get do
      companies = Company.es_search(params)

      present companies, with: Entities::CompanyForIndex
    end

    desc '创建公司'
    params do
      requires :name, type: String, desc: '公司名称'
      optional :logo, type: File, desc: 'logo'
      optional :website, type: String, desc: '网址'
      requires :one_sentence_intro, type: String, desc: '一句话简介'
      optional :detailed_intro, type: String, desc: '公司详细介绍'
      requires :location_province_id, type: Integer, desc: '省份'
      requires :location_city_id, type: Integer, desc: '城市'
      optional :detailed_address, type: String, desc: '详细地址'
      optional :business_data_id, type: Integer, desc: '工商数据'
      optional :sector_ids, type: Array[Integer], desc: '所属行业'
      optional :tag_ids, type: Array[Integer], desc: '标签'
      optional :contact_ids, type: Array[Integer], desc: '联系人'
    end
    post do

    end

    resource ':id' do
      before do
        @company = Company.find params[:id]
      end

      desc '编辑公司信息'
      params do
        requires :name, type: String, desc: '公司名称'
        optional :website, type: String, desc: '网址'
        optional :sector_ids, type: Array[Integer], desc: '所属行业'
        requires :one_sentence_intro, type: String, desc: '一句话简介'
        requires :location_province_id, type: Integer, desc: '省份'
        requires :location_city_id, type: Integer, desc: '城市'
        optional :detailed_address, type: String, desc: '详细地址'
        optional :detailed_intro, type: String, desc: '公司详细介绍'
        optional :tag_ids, type: Array[Integer], desc: '标签'
      end
      patch do

      end

      desc '工商数据'
      post :business_data do
        @company = Zombie::DmCompanyApi.find_by_id(params[:id])
        present @company.registered_name
      end

      desc '设为KA'
      params do
        requires :is_ka, type: Boolean, desc: '是否ka'
      end
      patch :ka do

      end

      desc '融资事件'
      get :financing_events do
        @invest_events = Zombie::DmInvestevent.includes(:company, :invest_type, :invest_round).order_by_date.public_data.not_deleted.where(company_id: params[:id]).paginate(:page => params[:page] || 1, :per_page => params[:page_size] || 4)._select(:id, :company_logo, :company_name, :company_slogan, :company_category_id, :company_sub_category_id, :company_location_city_id, :birth_date, :invest_round_id, :invest_type_id, :invest_batch, :detail_money, :detail_money_unit, :currency_id, :is_modify, :company_location_province_id, :company_location_city_id, :invest_type_and_batch_desc, :deleted_at, :detail_money_des, :deleted_note, :recover_note, :company_id, :post_money_des)
        present @invest_events
      end

      desc '竞争公司'
      get :competing_companies do

      end

      desc '新闻报道'
      get :news do

      end
    end
  end

  # mount AddressApi
  mount ContactApi, with: {owner: 'companies'}
end
