module Entities
  class UserForShow < Base
    expose :id, documentation: {type: 'integer', desc: '用户id', required: true}
    expose :name, documentation: {type: 'string', desc: '用户姓名', required: true}
    expose :en_name, documentation: {type: 'string', desc: '英文姓名', required: true}
    expose :team, using: Entities::TeamLite, documentation: {type: Entities::TeamLite, desc: '团队', required: true}
    expose :bu, using: Entities::TeamLite, documentation: {type: Entities::TeamLite, desc: 'bu', required: true}
    expose :grade_desc, documentation: {type: 'string', desc: '内部职务', required: true}
    expose :user_title, using: Entities::UserTitle, documentation: {type: Entities::UserTitle, desc: 'Title', required: true}
    expose :leader, using: Entities::UserLite, documentation: {type: Entities::UserLite, desc: '汇报人', required: true}
    expose :email, documentation: {type: 'string', desc: '邮箱', required: true}
    expose :wechat, documentation: {type: 'string', desc: '微信', required: true}
    expose :tel, documentation: {type: 'string', desc: '电话', required: true}

    expose :avatar_attachment, as: :avatar, using: Entities::File, documentation: {type: Entities::File, desc: '用户头像', required: true}
  end
end