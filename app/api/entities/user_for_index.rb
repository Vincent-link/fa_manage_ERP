module Entities
  class UserForIndex < Base
    expose :id, documentation: {type: 'integer', desc: '用户id', required: true}
    expose :name, documentation: {type: 'string', desc: '用户姓名', required: true}
    expose :email, documentation: {type: 'string', desc: '用户邮箱', required: true}
    expose :team_name, documentation: {type: 'integer', desc: '团队', required: true}
    expose :bu_id, documentation: {type: 'integer', desc: '部门', required: true}
    expose :leader, using: Entities::UserLite
    expose :user_title, using: Entities::UserTitle
    expose :grade_name, documentation: {type: 'integer', desc: '内部职务', required: true}
    expose :role, using: Entities::Role
    expose :wechat, documentation: {type: 'string', desc: '微信', required: true}
  end
end
