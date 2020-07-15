module Entities
  class Attachment < Base
    expose :id, documentation: {type: 'integer', desc: '文件id'}
    expose :filename, documentation: {type: 'string', desc: '文件名'}
    expose :organization, if: lambda { |ins, options| ins.record_type == 'TrackLog' && options[:organizations].present?}, documentation: {type: 'Entities::IdName', desc: '机构'} do |ins, options|
      organization = options[:organizations][ins.record_id]
      {
          id: organization&.id,
          name: organization&.name
      }
    end
    expose :name, as: :file_type, documentation: {type: 'string', desc: '文件类型'}
    expose :blob, using: Entities::Blob
  end
end
