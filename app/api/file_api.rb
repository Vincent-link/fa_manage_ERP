class FileApi < Grape::API
  helpers ::Helpers::FileHelpers

  resource :files do
    desc 'oss upload url'
    params do
      requires :filename, type: String, desc: '文件名'
      requires :byte_size, type: Integer, desc: '文件大小'
      requires :checksum, type: String, desc: '检验码'
      requires :content_type, type: String, desc: '文件类型'
      requires :metadata, type: JSON, desc: '元数据'

      requires :is_static, type: Boolean, desc: '是否静态文件', default: false
      optional :upload_type, type: String, desc: "上传类型：#{ConfigBox.upload_type_hash.invert}", values: ConfigBox.upload_type_values
    end

    get :oss_upload_url do
      bucket = params[:is_static] ? 'arrow-fa/static' : 'arrow-fa/privatic'
      auth_type(params[:upload_type]) if params[:upload_type].present?
      key_prefix = params[:upload_type] || 'temp'
      key = "#{bucket}/#{key_prefix}/#{ActiveStorage::Blob.generate_unique_secure_token}"
      blob = ActiveStorage::Blob.create!(params.slice(:filename, :byte_size, :checksum, :content_type, :metadata).merge(key: key))
      url = blob.service_url_for_direct_upload
      {
          url: url,
          path: key,
          blob_id: blob.id
      }
    end
  end
end
