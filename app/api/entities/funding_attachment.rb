module Entities
  class FundingAttachment < Base
    expose :file_bp, with: Entities::Attachment, documentation: {type: 'Entities::Attachment', desc: 'bp'}
    expose :file_nda, with: Entities::Attachment, documentation: {type: 'Entities::Attachment', desc: 'nda'}
    expose :file_model, with: Entities::Attachment, documentation: {type: 'Entities::Attachment', desc: 'model'}
    expose :file_nda, with: Entities::Attachment, documentation: {type: 'Entities::Attachment', desc: 'nda'}
    expose :file_el, with: Entities::Attachment, documentation: {type: 'Entities::Attachment', desc: 'el'}
    expose :file_materials, with: Entities::Attachment, documentation: {type: 'Entities::Attachment', desc: '其他', is_array: true}
    expose :file_ts, documentation: {type: 'Entities::Attachment', desc: '其他', is_array: true} do |ins, options|
      Entities::Attachment.represent ins[:file_ts], options
    end
    expose :file_spa, documentation: {type: 'Entities::Attachment', desc: '其他', is_array: true} do |ins, options|
      Entities::Attachment.represent ins[:file_spa], options
    end
  end
end