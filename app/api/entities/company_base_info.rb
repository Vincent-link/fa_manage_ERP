module Entities
  class CompanyBaseInfo < Base
    expose :id, documentation: {type: 'integer', desc: '公司id'}
    expose :name, documentation: {type: 'string', desc: '公司名称'}
    expose :sector, documentation: {type: 'json', desc: '行业'} do |ins|
      {

      }
    end
    expose :registered_name, documentation: {type: 'string', desc: '工商名'}
    expose :logo, documentation: {type: 'string', desc: '公司logo'}
    expose :address, with: Entities::Address, documentation: {type: 'string', desc: '地址'}
  end
end