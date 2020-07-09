module Entities
  class UserMyCurrent < Base
    expose :id, documentation: {type: 'integer', desc: '用户id', required: true}
    expose :name, documentation: {type: 'string', desc: '用户姓名', required: true}
    expose :avatar_attachment, as: :avatar, using: Entities::File, documentation: {type: Entities::File, desc: '用户头像', required: true}
    expose :has_sub_user, documentation: {type: 'boolean', desc: '用户id', required: true} do |user|
      user.sub_users.exists?
    end
    expose :funding_status_sort, documentation: {type: 'integer', desc: '状态排序', is_array: true} do |ins|
      ins.funding_status_sort || 'Funding'.constantize.status_values
    end
  end
end
