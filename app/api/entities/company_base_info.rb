module Entities
  class CompanyBaseInfo < Base
    expose :id, documentation: {type: 'integer', desc: '公司id'}
    expose :name, documentation: {type: 'string', desc: '公司名称'}
    expose :sector, documentation: {type: 'Entites::IdName', desc: '行业'} do |ins|
          '假数据'
    end
    expose :registered_name, documentation: {type: 'string', desc: '工商名'} do |ins|
      '假数据'
    end
    expose :com_desc, documentation: {type: 'string', desc: '公司简介'} do |ins|
      '假数据'
    end
    expose :logo, documentation: {type: 'string', desc: '公司logo'} do |ins|
      '假数据'
    end
    expose :location_id, documentation: {type: 'integer', desc: '行业'} do |ins|
      '假数据'
    end
    # expose :address, with: Entities::Address, documentation: {type: 'string', desc: '地址'}
  end
end