module Entities
  class CompanyLite < Base
    expose :id, documentation: {type: 'integer', desc: '公司id'}
    expose :name, documentation: {type: 'string', desc: '公司名称'}
  end
end