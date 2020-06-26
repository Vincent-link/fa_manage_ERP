class KnowledgeBaseFileApi < Grape::API
  mounted do
    resource configuration[:owner] do
      resource ':id' do
        desc "上传文件"
        params do
          requires :file, type: Hash, desc: '文件' do
            optional :id, type: Integer, desc: 'file_id 已有文件id'
            requires :blob_id, type: Integer, desc: 'blob_id 新文件id'
          end
          optional :file_desc, type: String, desc: "简介"
        end
        post do
          if params[:file].present? && params[:file][:blob_id].present?
            KnowledgeBase.transaction do
              ActiveStorage::Blob.find(params[:file][:blob_id]).update!(user_id: User.current.id, file_desc: params[:file_desc])
              ActiveStorage::Attachment.create!(name: 'files', record_type: 'KnowledgeBase', record_id: params[:id], blob_id: params[:file][:blob_id])
            end
          end
        end

      end
    end
  end

  resources :knowledge_base_files do
    desc "搜索"
    params do
      optional :query, type: String, desc: "搜索文件"
      optional :page, type: Integer, desc: '页数', default: 1
      optional :page_size, as: :per_page, type: Integer, desc: '页数', default: 10
    end
    get :search do
      files = ActiveStorage::Attachment.joins(:blob).where(record_type: "KnowledgeBase").where("active_storage_blobs.filename like ?", "%#{params[:query]}%")
      users = User.where(id: files.map(&:user_id)).index_by(&:id)

      present files.paginate(page: params[:page], per_page: params[:per_page]), with: Entities::KnowledgeBaseFile, users: users, folders: "folders"
    end

    resource ':attachment_id' do
      before do
        @file = ActiveStorage::Attachment.find(params[:attachment_id])
      end
      desc "预览"
      get :preview do

      end

      desc "下载"
      get :download do

      end

      desc "移动"
      params do
        requires :folder_id, type: Integer, desc: "文件夹id"
      end
      post :move do
        raise "无权限！" if User.current.id != @file.blob.user_id
        @file.update!(record_id: params[:folder_id], record_type: "KnowledgeBase", name: "files")
      end

      desc "删除"
      delete do
        @file.destroy!
      end
    end
  end
end
