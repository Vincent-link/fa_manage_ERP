class CompanyApi < Grape::API
  resource :companies do
    desc '获取所有公司'
    params do
      optional :query, type: String, desc: '检索文本', default: '*'
      optional :sector_ids, type: Array[Integer], desc: '行业'
      optional :is_ka, type: Boolean, desc: 'KA'
      optional :recent_financing_ids, type: Array[Integer], desc: '最近融资'
      requires :page, type: Integer, desc: '页数', default: 1
      optional :page_size, as: :per_page, type: Integer, desc: '每页条数', default: 30
    end
    get do
      companies = Company.es_search(params)
      present companies, with: Entities::CompanyForIndex
    end

    desc '创建公司'
    params do
      requires :name, type: String, desc: '公司名称'
      optional :logo, type: Hash, desc: '头像' do
        optional :id, type: Integer, desc: 'file_id 已有文件id'
        optional :blob_id, type: Integer, desc: 'blob_id 新文件id'
      end
      optional :website, type: String, desc: '网址'
      requires :one_sentence_intro, type: String, desc: '一句话简介'
      optional :detailed_intro, type: String, desc: '公司详细介绍'
      requires :location_province_id, type: Integer, desc: '地址'
      requires :location_city_id, type: Integer, desc: '地址'
      optional :detailed_address, type: String, desc: '详细地址'
      optional :registered_name, type: Integer, desc: '工商数据'
      requires :sector_id, type: Integer, desc: '所属行业'
      optional :company_tag_ids, type: Array[Integer], desc: '标签'
      requires :contacts, type: Array[JSON], desc: '联系人' do
        requires :name, type: String, desc: '姓名'
        optional :position, type: Integer, desc: '职位'
        optional :tel, type: String, desc: '电话'
        optional :email, type: String, desc: '邮箱'
        optional :wechat, type: String, desc: '微信'
      end
    end
    post do
      Company.transaction do
        tags_params = params.delete(:company_tag_ids)
        logo = params.delete(:logo)
        contacts_params = params.delete(:contacts)
        params[:registered_name] ||= ""

        @company = Company.create!(params)
        @company.company_tag_ids = tags_params

        if logo.present?
          ActiveStorage::Attachment.create!(name: 'logo', record_type: 'Company', record_id: @company.id, blob_id: logo[:blob_id])
        end

        contacts_params.map { |e| Contact.create!(e.merge(company_id: @company.id)) }

        # 从金丝雀获取最近融资
        @company.syn_recent_financing
        # 更新一级行业
        @company.syn_root_sector(params[:sector_id])

        present @company, with: Entities::CompanyForShow
      end
    end

    desc '关联企业搜索'
    params do
      requires :name, type: String, desc: '名称'
    end
    get :registered_company_search do
      registered_companies = Zombie::DmRegisteredCompany.where("name like ?", "%#{params[:name]}%")._select(:name, :info_url, :id, :address, :artificial_person).inspect
      present registered_companies, with: Entities::RegisteredCompany
    end

    desc '关联企业添加'
    params do
      requires :name, type: String, desc: '工商名称'
      requires :info_url, type: String, desc: '天眼查网址', regexp: /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/ix
    end
    post :registered_company_add do
      @relation_company = Zombie::DmRegisteredCompany.create_registered_company(declared(params))
    end

    desc '上市公司股票信息', entity: Entities::CompanyTicker
    params do
      optional :name, type: String, desc: "公司名称"
      optional :page, type: Integer, desc: '页数', default: 1
      optional :page_size, as: :per_page, type: Integer, desc: '每页条数', default: 30
    end
    get :ticker do
      company_tickers = Zombie::DmCompany.includes(:company_tickers)._select(:name, :ticker).search_by_keyword(params["name"], true).paginate(page: params[:page], per_page: params[:per_page]).inspect
      present company_tickers, with: Entities::CompanyTicker
    end

    resource ':id' do
      before do
        @company = Company.find params[:id]
      end

      desc '公司详情', entity: Entities::CompanyForShow
      get do
        present @company, with: Entities::CompanyForShow
      end

      desc '编辑公司信息'
      params do
        optional :name, type: String, desc: '公司名称'
        optional :logo, type: Hash, desc: '头像' do
          optional :id, type: Integer, desc: 'file_id 已有文件id'
          optional :blob_id, type: Integer, desc: 'blob_id 新文件id'
        end
        optional :website, type: String, desc: '网址'
        optional :sector_id, type: Integer, desc: '所属行业'
        optional :one_sentence_intro, type: String, desc: '一句话简介'
        optional :location_province_id, type: Integer, desc: '省份'
        optional :location_city_id, type: Integer, desc: '城市'
        optional :detailed_address, type: String, desc: '详细地址'
        optional :detailed_intro, type: String, desc: '公司详细介绍'
        optional :company_tag_ids, type: Array[Integer], desc: '标签'
        requires :part, type: String, desc: '更新区域', values: ['basic', 'head']
      end
      patch do
        part = params.delete(:part)
        case part
        when 'head'
          raise "名称不能为空" if params[:name].nil?
          raise "行业不能为空" if params[:sector_id].nil?
          raise "一句话介绍不能为空" if params[:one_sentence_intro].nil?
          raise "地点不能为空" if params[:location_city_id].nil? || params[:location_province_id].nil?
        when 'basic'
        end

        @company.company_tag_ids = params.delete(:company_tag_ids)

        logo = params.delete(:logo)
        if logo.present?
          if @company.logo_attachment.present?
            @company.logo_attachment.update(blob_id: logo[:blob_id])
          else
            ActiveStorage::Attachment.create!(name: 'logo', record_type: 'Company', record_id: params[:id], blob_id: logo[:blob_id])
          end
        end

        true if @company.update!(declared(params, include_missing: false))
      end

      desc '设为KA'
      params do
        requires :is_ka, type: Boolean, desc: '是否ka'
      end
      patch :ka do
        @company.update!(is_ka: params[:is_ka])
      end

      desc '竞争公司'
      params do
        requires :page, type: Integer, desc: '页数', default: 1
        optional :page_size, as: :per_page, type: Integer, desc: '每页条数', default: 30
      end
      get :competing_companies do

      end

      desc '新闻报道'
      params do
        requires :page, type: Integer, desc: '页数', default: 1
        optional :page_size, as: :per_page, type: Integer, desc: '每页条数', default: 30
      end
      get :news do

      end
    end
  end

  mount AddressApi, with: {owner: 'companies'}
  mount ContactApi, with: {owner: 'companies'}
end
