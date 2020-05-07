class EcmGroupApi < Grape::API
  resource :ecm_groups do
    desc 'ecm_group列表', entity: Array[Entities::EcmGroup]
    get do
      present EcmGroup.all, with: Entities::EcmGroup
    end

    desc '创建ecm_group', entity: Entities::EcmGroup
    params do
      requires :name, type: String, desc: '组名称'
      optional :sectors, type: Array[Integer], desc: '行业'
    end
    post do
      present EcmGroup.create!(declared(params)), with: Entities::EcmGroup
    end

    resource ':id' do
      before do
        @ecm_group = EcmGroup.find(params[:id])
      end

      desc '删除ecm_group'
      delete do
        @ecm_group.destroy!
      end

      desc '更新ecm_group', entity: Entities::EcmGroup
      params do
        requires :name, type: String, desc: '组名称'
        optional :sectors, type: Array[Integer], desc: '行业'
      end
      patch do
        present @ecm_group.update(declared(params)), with: Entities::EcmGroup
      end
    end
  end
end