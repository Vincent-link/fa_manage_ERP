module Entities
  class FileResult < Base
    expose :file_type, documentation: {type: 'string', desc: '文件类型'}
    expose :data, with: Entities::Attachment, documentation: {type: Entities::Attachment, desc: '文件'}
  end
end
