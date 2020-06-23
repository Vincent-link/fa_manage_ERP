module Entities
  class KnowledgeBaseFile < Base
    expose :id, documentation: {type: 'integer', desc: 'id'}
    expose :filename, documentation: {type: 'string', desc: '文件名'}
    expose :created_at, documentation: {type: 'date', desc: '上传时间'}
    expose :user_id, documentation: {type: 'string', desc: '上传人'}
    expose :file_desc, documentation: {type: 'string', desc: '简介'}
  end
end
