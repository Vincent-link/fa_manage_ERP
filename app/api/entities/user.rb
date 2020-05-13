module Entities
  class User < Base
    expose :id, documentation: {type: 'integer', desc: '用户id', required: true}
    expose :name, documentation: {type: 'string', desc: '用户姓名', required: true}
    expose :email, documentation: {type: 'string', desc: '用户邮箱', required: true}
    expose :bu_id, documentation: {type: 'integer', desc: '部门', required: true}
    expose :leader, documentation: {type: 'integer', desc: '上级负责人', required: true}
    expose :user_title_id, documentation: {type: 'integer', desc: '对外Title', required: true}
    expose :grade_id, documentation: {type: 'integer', desc: '内部职务', required: true}
    expose :wechat, documentation: {type: 'string', desc: '微信', required: true}
    
    expose :proxier_id
  end
end