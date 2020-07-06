class FileApi < Grape::API
  helpers ::Helpers::FileHelpers

  resource :files do
    desc 'oss upload url'
    params do
      requires :filename, type: String, desc: '文件名'
      requires :byte_size, type: Integer, desc: '文件大小'
      requires :checksum, type: String, desc: '检验码'
      requires :content_type, type: String, desc: '文件类型'
      requires :upload_type, type: String, desc: "上传类型：#{ConfigBox.upload_type_hash.invert}", values: ConfigBox.upload_type_values
    end

    get :oss_upload_url do
      params[:user_id] = current_user.id
      bucket = ConfigBox.upload_type_value_code(params[:upload_type], :is_static).first ? 'static' : 'private'
      key = "#{bucket}/#{params[:upload_type]}/#{ActiveStorage::Blob.generate_unique_secure_token}"
      blob = ActiveStorage::Blob.create!(params.slice(:filename, :byte_size, :checksum, :content_type, :user_id).merge(key: key, metadata: {identified: true, analyzed: true}))
      url = blob.service_url_for_direct_upload
      {
          url: url,
          blob_id: blob.id
      }
    end
  end
end
