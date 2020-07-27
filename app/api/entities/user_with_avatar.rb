module Entities
  class UserWithAvatar < UserLite
    expose :avatar_attachment, as: :avatar, using: Entities::File, documentation: {type: Entities::File, desc: '用户头像', required: true}
  end
end