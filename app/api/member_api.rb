class MemberApi < Grape::API
  resource :organizations do
    resource ':id' do
      desc '投资人列表', entity: Entities::MemberForIndex
      params do
        requires :layout, type: String, desc: 'index/select', default: 'index'
        optional :page, type: Integer, desc: '页数', default: 1
        optional :page_size, as: :per_page, type: Integer, desc: '每页条数', default: 30
      end
      get :members do
        organization = Organization.find(params[:id])
        case params[:layout]
        when 'index'
          present organization.members.paginate(page: params[:page], per_page: params[:per_page]), with: Entities::MemberForIndex
        when 'select'
          present organization.members.paginate(page: params[:page], per_page: params[:per_page]), with: Entities::MemberLite
        end
      end

      desc '创建投资人', entity: Entities::MemberForShow
      params do
        optional :id, type: Integer, desc: '公海投资人id'
        optional :name, type: String, desc: '投资人名称'
        optional :en_name, type: String, desc: '投资人英文名称'
        optional :email, type: String, desc: '投资人邮箱'
        optional :tel, type: String, desc: '手机号'
        optional :wechat, type: String, desc: '微信'
        optional :card_file, type: Hash, desc: '名片' do
          optional :id, type: Integer, desc: 'file_id 已有文件id'
          optional :blob_id, type: Integer, desc: 'blob_id 新文件id'
        end
        optional :avatar_file, type: Hash, desc: '头像' do
          optional :id, type: Integer, desc: 'file_id 已有文件id'
          optional :blob_id, type: Integer, desc: 'blob_id 新文件id'
        end
        optional :tel, type: String, desc: '手机号'
        optional :sponsor_id, type: Integer, desc: '来源'
        optional :position_rank_id, type: Integer, desc: '职级'
        optional :position, type: String, desc: '实际职位'
        optional :address_id, type: Integer, desc: '办公地点'
        optional :investor_tag_ids, type: Array[Integer], desc: '热点标签'
        optional :sector_ids, type: Array[Integer], desc: '关注行业'
        optional :round_ids, type: Array[Integer], desc: '关注轮次'
        optional :currency_ids, type: Array[Integer], desc: '可投币种'
        optional :scale_ids, type: Array[Integer], desc: '投资规模'
        optional :team_ids, type: Array[Integer], desc: '团队'
        optional :followed_location_ids, type: Array[Integer], desc: '关注地区id'
        optional :covered_by, type: Array[Integer], desc: '对接成员'
        optional :is_head, type: Boolean, desc: '是否高层'
        optional :is_ic, type: Boolean, desc: '是否投委会'
        optional :is_president, type: Boolean, desc: '是否最高决策人'
        optional :report_line, type: Array[JSON] do
          optional :superior_id, type: Integer, desc: '上级负责人id'
          optional :report_type, type: Integer, desc: '汇报类型'
        end
        optional :solid_lower_ids, type: Array[Integer], desc: '实线下级'
        optional :virtual_lower_ids, type: Array[Integer], desc: '虚线下级'
        optional :ir_review, type: String, desc: 'ir'
        optional :intro, type: String, desc: '简介'
      end
      post :members do
        present Member.create!(params), with: Entities::MemberForShow
      end
    end
  end

  resource :members do
    desc '投资人列表', entity: Entities::MemberForIndex
    params do
      optional :query, type: String, desc: '检索文本', default: '*'
      optional :followed, type: Boolean, desc: '我关注的'
      optional :sector_ids, type: Array[Integer], desc: '行业', default: []
      optional :round, type: Array[Integer], desc: '轮次', default: []
      optional :position_rank_id, type: Array[Integer], desc: '职级'
      optional :currency, type: Array[Integer], desc: '币种', default: []
      optional :scale, type: Array[Integer], desc: '投资规模', default: []
      optional :location, type: Array[Integer], desc: '所在城市', default: []
      optional :level, type: Array[String], desc: '分级'
      optional :investor_group_id, type: Integer, desc: '投资人名单id'
      optional :covered_by, type: Integer, desc: '对接人id'
      requires :layout, type: String, desc: '数据样式', default: 'index', values: ['index', 'card', 'select', 'export', 'ecm_group']
      optional :page, type: Integer, desc: '页数', default: 1
      optional :page_size, as: :per_page, type: Integer, desc: '每页条数', default: 30
      optional :order_by, type: String, values: ['level', 'last_investevent_date'], desc: '排序字段'
      optional :order_type, type: String, values: ['asc', 'desc'], desc: '排序类型', default: 'desc'
      optional :tel, type: String, desc: '手机号'
    end
    get do
      members = Member.es_search(params, includes: :organization)
      case params[:layout]
      when 'index'
        present members, with: Entities::MemberForIndex
      when 'select'
        present members, with: Entities::MemberLite
      when 'card'
        present members, with: Entities::MemberForCard
      when 'export'
        present members.limit 300 #todo export
      when 'ecm_group'
        members = Member.es_search(params, includes: [:organization, :users])
        present members, with: Entities::MemberForEcmGroup
      end
    end

    desc '检索公海投资人', entity: Entities::DmMemberLite
    params do
      optional :query, type: String, desc: '检索', regexp: /..+/
      optional :tel, type: String, desc: '手机号', regexp: /\d{8}\d+/
      optional :organization_id, type: Integer, desc: '限定机构id'
    end
    get :dm_search do
      dm_members = Zombie::DmMember
      dm_members = dm_members.by_investor(params[:organization_id]) if params[:organization_id]
      dm_members = dm_members.search_by_query_assist(params[:query], 'Investor') if params[:query]
      dm_members = dm_members.where(contact_tel: params[:contact_tel]) if params[:contact_tel]

      dm_members = dm_members.limit(10).inspect
      member_hash = Member.where(id: dm_members.map(&:id)).index_by(&:id)

      present dm_members, with: Entities::DmMemberLite, member_hash: member_hash
    end


    resource ':id' do
      desc '投资人详情', entity: Entities::MemberForShow
      get do
        present Member.find(params[:id]), with: Entities::MemberForShow
      end

      desc '更新投资人', entity: Entities::MemberForShow
      params do
        optional :name, type: String, desc: '投资人名称'
        optional :en_name, type: String, desc: '投资人英文名称'
        optional :email, type: String, desc: '投资人邮箱'
        optional :tel, type: String, desc: '手机号'
        optional :wechat, type: String, desc: '微信'
        optional :card_file, type: Hash, desc: '名片' do
          optional :id, type: Integer, desc: 'file_id 已有文件id'
          optional :blob_id, type: Integer, desc: 'blob_id 新文件id'
        end
        optional :avatar_file, type: Hash, desc: '头像' do
          optional :id, type: Integer, desc: 'file_id 已有文件id'
          optional :blob_id, type: Integer, desc: 'blob_id 新文件id'
        end
        optional :tel, type: String, desc: '手机号'
        optional :organization_id, type: Integer, desc: '机构id'
        optional :sponsor_id, type: Integer, desc: '来源'
        optional :position_rank_id, type: Integer, desc: '职级'
        optional :position, type: String, desc: '实际职位'
        optional :address_id, type: Integer, desc: '办公地点'
        optional :investor_tag_ids, type: Array[Integer], desc: '热点标签'
        optional :sector_ids, type: Array[Integer], desc: '关注行业'
        optional :round_ids, type: Array[Integer], desc: '关注轮次'
        optional :currency_ids, type: Array[Integer], desc: '可投币种'
        optional :scale_ids, type: Array[Integer], desc: '投资规模'
        optional :team_ids, type: Array[Integer], desc: '团队'
        optional :followed_location_ids, type: Array[Integer], desc: '关注地区id'
        optional :covered_by, type: Array[Integer], desc: '对接成员'
        optional :is_head, type: Boolean, desc: '是否高层'
        optional :is_ic, type: Boolean, desc: '是否投委会'
        optional :is_president, type: Boolean, desc: '是否最高决策人'
        optional :report_line, type: Array[JSON] do
          optional :superior_id, type: Integer, desc: '上级负责人id'
          optional :report_type, type: Integer, desc: '汇报类型'
        end
        optional :solid_lower_ids, type: Array[Integer], desc: '实线下级'
        optional :virtual_lower_ids, type: Array[Integer], desc: '虚线下级'
        optional :ir_review, type: String, desc: 'ir'
        optional :intro, type: String, desc: '简介'
        requires :part, type: String, desc: '更新区域', values: ['head', 'info']
      end
      patch do
        params[:card] = ActionDispatch::Http::UploadedFile.new(params[:card]) if params[:card]
        params[:avatar] = ActionDispatch::Http::UploadedFile.new(params[:avatar]) if params[:avatar]
        #todo part validation
        params.delete :part
        member = Member.find(params[:id])
        member.update!(params)
        present member, with: Entities::MemberForShow
      end

      desc '删除投资人'
      delete do
        member = Member.find(params[:id])
        member.destroy!
      end

      desc '离职投资人'
      params do
        optional :organization_id, type: Integer, desc: '转移目标机构'
        requires :is_dimission, type: Boolean, desc: '是否离职'
      end
      patch :dismiss do
        member = Member.find(params[:id])
        member.update declared(params, include_missing: false)
        present member, with: Entities::MemberForShow
      end

      desc '关联融资事件'
      params do
        requires :event_id, type: Integer, desc: '关联事件ID'
      end
      patch :relate_event do
        Zombie::DmInvestevent._by_id(params[:event_id]).add_members(params[:id], true)
      end
    end
  end

  mount CommentApi, with: {owner: 'members'}
end
