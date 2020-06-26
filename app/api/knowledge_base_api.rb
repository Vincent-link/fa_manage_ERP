class KnowledgeBaseApi < Grape::API
  resources :knowledge_bases do
    desc "所有目录"
    params do
      requires :knowledge_base_type, type: String, desc: "文件夹类型", values: ["research_report", "sector_report"]
    end
    get do
      params[:knowledge_base_type] = KnowledgeBase.knowledge_base_type_config[params[:knowledge_base_type].to_sym][:value]
      knowledge_bases = KnowledgeBase.where(knowledge_base_type: params[:knowledge_base_type])
      present knowledge_bases, with: Entities::KnowledgeBase
    end

    desc "创建目录"
    params do
      requires :knowledge_base_type, type: String, desc: "文件夹类型", values: ["research_report", "sector_report"]
      requires :name, type: String, desc: "名称"
      optional :parent_id, type: Integer, desc: "父级id"
    end
    post do
      params[:knowledge_base_type] = KnowledgeBase.knowledge_base_type_config[params[:knowledge_base_type].to_sym][:value]
      KnowledgeBase.create!(declared(params))
    end

    resource ':id' do
      before do
        @knowledge_base = KnowledgeBase.find(params[:id])
      end

      desc "获取子目录"
      get do
        present @knowledge_base.children, with: Entities::KnowledgeBase
      end

      desc "获取文件"
      params do
        optional :page, type: Integer, desc: '页数', default: 1
        optional :page_size, as: :per_page, type: Integer, desc: '页数', default: 10
      end
      get :files do
        users = @knowledge_base.files_attachments.map do |file|
          {
            id: file.user_id,
            user: User.find(file.user_id).name,
          }
        end
        present @knowledge_base.files_attachments.paginate(page: params[:page], per_page: params[:per_page]), with: Entities::KnowledgeBaseFile, users: users
      end

      desc "删除目录"
      delete do
        @knowledge_base.destroy
      end

      desc "更新目录"
      params do
        requires :name, type: String, desc: "名称"
      end
      patch do
        @knowledge_base.update!(name: params[:name])
      end
    end
  end

  mount KnowledgeBaseFileApi, with: {owner: 'knowledge_bases'}
end
