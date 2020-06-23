class KnowledgeBaseFileApi < Grape::API
  mounted do
    resource configuration[:owner] do
      resource ':id' do
        before do
          @knowledge_base = KnowledgeBase.find(params[:id])
        end

        desc "上传文件"
        params do
          optional :file, type: Hash, desc: '文件' do
            optional :id, type: Integer, desc: 'file_id 已有文件id'
            optional :blob_id, type: Integer, desc: 'blob_id 新文件id'
          end
          optional :file_desc, type: String, desc: "简介"
        end
        post do
          if params[:file].present?
            ActiveStorage::Attachment.create!(name: 'files', record_type: 'KnowledgeBase', record_id: params[:id], blob_id: params[:file][:blob_id])
          end
        end

        resources :files do
          resource ':file_id' do
            before do
              @file = ActiveStorage::Attachment.find(params[:file_id])
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
              @file.update!(record_id: params[:folder_id])
            end

            desc "删除"
            delete do
              @file.destroy
            end
          end
        end

      end
    end
  end

  resources :KnowledgeBaseFiles do

  end
end
