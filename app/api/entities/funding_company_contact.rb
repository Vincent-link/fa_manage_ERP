module Entities
  class FundingCompanyContact < Base
    expose :id, documentation: {type: 'integer', desc: '公司团队成员id'}
    expose :name, documentation: {type: 'string', desc: '名字'}
    expose :position, documentation: {type: 'Entities::IdName', desc: '职位'} do |ins|
      {
          id: ins.position_id,
          name: ins.position_desc,
      }
    end
    expose :email, documentation: {type: 'string', desc: '邮箱'}
    expose :mobile, documentation: {type: 'string', desc: '手机号码'}
    expose :wechat, documentation: {type: 'string', desc: '微信号'}
    expose :description, documentation: {type: 'string', desc: '简介'}
  end
end