module Entities
  class EmailTo < Base
    expose :id, as: :relation_id, documentation: {type: 'integer', desc: '中间表id, 由于收件人可能重复，称谓可能不同，所以增加了这个唯一标识'}
    expose :toable_id, as: :id, documentation: {type: 'integer', desc: '收件人id'}
    expose :toable_type, as: :type, documentation: {type: 'string', desc: '收件人类型'} do |ins|
      ins.toable_type.underscore
    end
    expose :name, documentation: {type: 'string', desc: '姓名'} do |ins|
      ins.person_title || ins.toable&.name
    end
    expose :email, documentation: {type: 'string', desc: '邮箱'} do |ins|
      ins.toable&.email
    end

    expose :organization, documentation: {type: Entities::IdName, desc: '邮箱'} do |ins|
      organizaiton = ins.email_to_group.organization
      {
          id: organizaiton&.id,
          name: organizaiton&.name
      }
    end

    expose :avatar, documentation: {type: Entities::File, desc: '用户头像', required: true} do |ins|
      Entities::File.represent ins.toable&.avatar_attachment
    end
  end
end
