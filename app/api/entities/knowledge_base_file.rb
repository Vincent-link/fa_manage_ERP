module Entities
  class KnowledgeBaseFile < Base
    expose :id, documentation: {type: 'integer', desc: '文件id（attachment）'}
    expose :filename, documentation: {type: 'string', desc: '文件名'}
    expose :created_at, documentation: {type: 'date', desc: '上传时间'}
    expose :user, documentation: {type: 'string', desc: '上传人'} do |ins, options|
      if options[:users].has_key? ins.user_id
        {
          id: ins.user_id,
          name: options[:users][ins.user_id].name
        }
      end
    end
    expose :folder, if: lambda {|ins, options| options[:folders].present? }, documentation: {type: 'string', desc: '上传人'} do |ins, options|
      {
        id: ins.record.id,
        name: ins.record.name
      }
    end
    expose :file_desc, documentation: {type: 'string', desc: '简介'}
  end
end
