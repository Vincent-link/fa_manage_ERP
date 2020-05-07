class MemberApi < Grape::API
  resource :organizations do
    resource ':id' do
      desc '投资人列表', entity: Entities::MemberForIndex
      params do
        requires :layout, type: String, desc: 'index/select', default: 'index'
      end
      get :members do
        organization = Organization.find(params[:id])
        case params[:layout]
        when 'index'
          present organization.members, with: Entities::MemberForIndex
        when 'select'
          present organization.members, with: Entities::MemberLite
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
        optional :card, type: String, desc: '名片'
        optional :tel, type: String, desc: '手机号'
        optional :sponsor_id, type: Integer, desc: '来源'
        optional :position, type: Integer, desc: '职级'
        optional :title, type: String, desc: '实际职位'
        optional :address_id, type: Integer, desc: '办公地点'
        optional :tag_ids, type: Array[Integer], desc: '机构标签'
        optional :sector_ids, type: Array[Integer], desc: '关注行业'
        optional :round_ids, type: Array[Integer], desc: '关注轮次'
        optional :currency_ids, type: Array[Integer], desc: '可投币种'
        optional :scale_ids, type: Array[Integer], desc: '投资规模'
        optional :team, type: String, desc: '团队'
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
      optional :sector, type: Array[Integer], desc: '行业', default: []
      optional :round, type: Array[Integer], desc: '轮次', default: []
      optional :position_rank_id, type: Array[Integer], desc: '职级'
      optional :currency, type: Array[Integer], desc: '币种', default: []
      optional :scale, type: Array[Integer], desc: '投资规模', default: []
      optional :location, type: Array[Integer], desc: '所在城市', default: []
      optional :level, type: Array[String], desc: '分级'
      optional :investor_group_id, type: Integer, desc: '投资人名单id'

      requires :layout, type: String, desc: 'index/select/export', default: 'index'
      requires :page, type: Integer, desc: '页数', default: 1
      requires :per_page, type: Integer, desc: '每页条数', default: 30
    end
    get do
      members = Member.es_search(params)
      case params[:layout]
      when 'index'
        present members, with: Entities::MemberForIndex
      when 'select'
        present members, with: Entities::MemberLite
      when 'export'

      end
    end

    resource ':id' do
      desc '投资人详情', entity: Entities::MemberForShow
      get do
        present Member.find(params[:id]), with: Entities::MemberForShow
      end
    end
  end
end