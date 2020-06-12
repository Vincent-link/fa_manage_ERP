module Entities
  class File < Base
    expose :id, documentation: {type: 'integer', desc: '地址id'}
    expose :filename, documentation: {type: 'string', desc: '文件名'}
    expose :service_url, documentation: {type: 'string', desc: 'url'}
    expose :byte_size, documentation: {type: 'integer', desc: '文件大小'}
  end
end