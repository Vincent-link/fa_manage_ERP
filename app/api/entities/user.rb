module Entities
  class User < Base
    expose :id, documentation: {type: 'integer', desc: '用户id', required: true}
    expose :name, documentation: {type: 'string', desc: '用户姓名', required: true} do |user, options|
      if options[:type].nil?
        user.name
      else
        options[:type] == "yes" ? user.name : ""
      end
    end
    expose :avatar_attachment, as: :avatar, using: Entities::File, documentation: {type: Entities::File, desc: '用户头像', required: true}
  end
end
