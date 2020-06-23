module Entities
  class Attachment < Base
    expose :id, documentation: {type: 'integer', desc: '文件id'}
    expose :filename, documentation: {type: 'string', desc: '文件名'}
    expose :organization, if: lambda { |ins, options| options[:organizations].present?}, documentation: {type: 'Entities::IdName', desc: '机构'} do |ins, options|
      organization = options[:organizations][ins.record_id]
      {
          id: organization&.id,
          name: organization&.name
      }
    end
    expose :blob, using: Entities::BlobFile
  end
end
