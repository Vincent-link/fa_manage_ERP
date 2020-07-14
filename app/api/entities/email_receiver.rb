module Entities
  class EmailReceiver < Base
    expose :id, as: :relation_id, documentation: {type: 'integer', desc: '中间表id，用作唯一key，抄送人可能没有id，所以加了这个relation_id用作唯一标识'}
    expose :receiverable_id, as: :id, documentation: {type: 'integer', desc: '收件人id'}
    expose :receiverable_type, as: :type, documentation: {type: 'string', desc: '收件人类型'} do |ins|
      ins.receiverable_type.underscore
    end
    expose :name, documentation: {type: 'string', desc: '姓名'} do |ins|
      ins.receiverable&.name
    end
    expose :email, documentation: {type: 'string', desc: '邮箱'} do |ins|
      ins.email || ins.receiverable&.email
    end
  end
end
