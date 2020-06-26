module Entities
  class KnowledgeBaseFile < Base
    expose :id, documentation: {type: 'integer', desc: 'id'}
    expose :filename, documentation: {type: 'string', desc: '文件名'}
    expose :created_at, documentation: {type: 'date', desc: '上传时间'}
    expose :user, documentation: {type: 'string', desc: '上传人'} do |ins, options|
      {
        id: ins.user_id,
        name: options[:users].select{|e| e[:id] == ins.user_id }.first[:user]
      }
    end
    expose :folder, if: lambda {|ins, options| options[:type].present? }, documentation: {type: 'string', desc: '上传人'}
    expose :file_desc, documentation: {type: 'string', desc: '简介'}
  end
end
