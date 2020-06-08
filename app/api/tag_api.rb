class TagApi < Grape::API
  resource :tags do
    resource ':id' do
      before do
        @tag = ActsAsTaggableOn::Tag.find(params[:id])
      end

      desc '修改'
      params do
        requires :name, type: String, desc: '名称'
      end
      patch do
        @tag.update(name: params[:name])
      end

      desc '删除'
      delete do
        @tag.destroy
      end
    end

  end
end
