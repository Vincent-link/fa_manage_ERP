module Entities
  class Blob < Base
    expose :id, as: :blob_id, documentation: {type: 'integer', desc: '地址id'}
    expose :filename, documentation: {type: 'string', desc: '文件名'}
    expose :service_url, documentation: {type: 'string', desc: 'url'}
    with_options(format_with: :time_to_s_minute) do
      expose :created_at, documentation: {type: 'string', desc: '上传时间'}
    end
    expose :user, documentation: {type: Entities::IdName, desc: '上传人'} do |ins|
      user = 'User'.constantize.find(ins.user_id)
      {
          id: user.id,
          name: user.name
      }
    end
  end
end