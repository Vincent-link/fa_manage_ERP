module Entities
  class FundingCompanyContact < Base
    expose :id, documentation: {type: 'integer', desc: '公司团队成员id'}
    expose :name, documentation: {type: 'integer', desc: '名字'}
    expose :position, documentation: {type: 'integer', desc: '职位'} do |ins|
      {
          id: ins.position_id,
          name: ins.position_desc,
      }
    end
    expose :name, documentation: {type: 'integer', desc: '名字'}
    expose :name, documentation: {type: 'integer', desc: '名字'}
  end
end