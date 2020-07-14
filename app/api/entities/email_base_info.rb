module Entities
  class EmailBaseInfo < Base
    expose :email_tos, as: :tos, with: Entities::EmailTo, documentation: {type: Entities::EmailTo, desc: '收件人', is_array: true}
    with_options(format_with: :time_to_s_minute) do
      expose :send_at, documentation: {type: 'string', desc: '发送时间'}
    end
    expose :status, documentation: {type: 'integer', desc: '状态'}
    expose :has_verification, documentation: {type: 'boolean', desc: '是否有审核'} do |ins|
      ins.verification.present?
    end
  end
end
