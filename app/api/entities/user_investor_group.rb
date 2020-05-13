module Entities
  class UserInvestorGroup < Base
    expose :id, documentation: {type: 'integer', desc: 'ecm组id', required: true}
    expose :name, documentation: {type: 'string', desc: '组名', required: true}
    expose :is_public, documentation: {type: 'boolean', desc: '是否公开'}
    expose :user, using: Entities::UserLite, documentation: {type: Entities::UserLite, desc: '创建人'}
    expose :member_count, documentation: {type: Integer, desc: '组内member数量'}
    expose :members, using: Entities::MemberForIndex, documentation: {type: Entities::MemberForIndex, desc: '投资人'}
    with_options(format_with: :time_to_s_minute) do
      expose :updated_at, documentation: {type: String, desc: '更新时间'}
    end
  end
end