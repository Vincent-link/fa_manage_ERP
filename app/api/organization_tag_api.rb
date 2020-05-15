class OrganizationTagApi < Grape::API
  resource :organization_tags do
    resources ':id' do
      before do
        @organization_tag = OrganizationTag.find(params[:id])
      end

      desc '删除标签'
      delete do
        @organization_tag.destroy!
      end

      desc '更新标签'
      params do
        requires :name, type: String, desc: '名称'
      end
      patch do
        re = params if @organization_tag.update(declared(params))
        present re, with: Entities::OrganizationTag
      end
    end
  end
end