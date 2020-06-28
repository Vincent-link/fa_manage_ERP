module Entities
  class Blob < Base
    expose :id, as: :blob_id, documentation: {type: 'integer', desc: '地址id'}
    expose :filename, documentation: {type: 'string', desc: '文件名'}
    expose :service_url, documentation: {type: 'string', desc: 'url'}
  end
end