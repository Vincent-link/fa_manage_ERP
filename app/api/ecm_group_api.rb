class EcmGroupApi < Grape::API
  resource :ecm_groups do
    desc 'ecm_group列表', entity: Array[Entities::EcmGroupForSelect]
    get do
      present EcmGroup.all, with: Entities::EcmGroupForSelect
    end

    desc '创建ecm_group', entity: Entities::EcmGroupForSelect
    params do
      requires :name, type: String, desc: '组名称'
      optional :sector_ids, type: Array[Integer], desc: '行业'
    end
    post do
      present EcmGroup.create!(declared(params)), with: Entities::EcmGroupForSelect
    end

    resource ':id' do
      before do
        @ecm_group = EcmGroup.find(params[:id])
      end

      desc '删除ecm_group'
      delete do
        @ecm_group.destroy!
      end

      desc 'ecm_group详情', entity: Entities::EcmGroupForShow
      get do
        present @ecm_group, with: Entities::EcmGroupForShow
      end

      desc 'ecm_group明细', entity: Entities::EcmGroupOrganization
      params do
        optional :page, type: Integer, desc: '页数', default: 1
        optional :page_size, as: :per_page, type: Integer, desc: '每页条数', default: 30
      end
      get :details do
        present @ecm_group.investor_group_organizations.paginate(page: params[:page], per_page: params[:page_size]), with: Entities::EcmGroupOrganization
      end

      desc '更新ecm_group', entity: Entities::EcmGroupForSelect
      params do
        requires :name, type: String, desc: '组名称'
        optional :sector_ids, type: Array[Integer], desc: '行业'
      end
      patch do
        @ecm_group.update(declared(params))
        present @ecm_group, with: Entities::EcmGroupForSelect
      end

      desc '添加投资人', entity: Entities::EcmGroupForShow
      params do
        requires :organization_id, type: Integer, desc: '机构id'
        requires :member_ids, type: Array[Integer], desc: '投资人id', default: []
        optional :tier, type: Integer, desc: '等级'
      end
      patch :details do
        org_relation = @ecm_group.investor_group_organizations.find_or_initialize_by(organization_id: params[:organization_id])
        org_relation.tier = params[:tier]
        org_relation.save!
        org_relation.investor_group_members.where.not(member_id: params[:member_ids]).destroy_all
        params[:member_ids].each do |member_id|
          org_relation.investor_group_members.find_or_create_by member_id: member_id do |m|
            m.investor_group_id = @ecm_group.id
          end
        end
        present @ecm_group, with: Entities::EcmGroupForShow
      end
    end
  end

  resource :ecm_group_details do
    resource ':id' do
      delete do
        detail = InvestorGroupOrganization.find(params[:id])
        detail.destroy!
        present detail.investor_group, with: Entities::EcmGroupForShow
      end
    end
  end
end