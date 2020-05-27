module Entities
  class UserForEvaluation < Base
    expose :id, documentation: {type: 'integer', desc: '用户id', required: true}
    expose :name, documentation: {type: 'string', desc: '用户姓名', required: true} do |user, options|
      user.name = "" if options[:type] == "no"
    end
    expose :avatar, using: Entities::File, if: ->(ins) {ins.avatar.present?}, documentation: {type: Entities::File, desc: '用户头像', required: true}
  end
end
