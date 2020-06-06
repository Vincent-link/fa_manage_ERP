module Entities
  class CompanyForIndex < Base
    expose :id, documentation: {type: 'integer', desc: '公司id'}
    expose :name, documentation: {type: 'string', desc: '公司名称'}
    expose :sector_list, documentation: {type: 'string', desc: '行业'} 
    expose :location_province_id, documentation: {type: 'integer', desc: '省份'} do |ins|
      '假数据'
    end

    expose :recent_financing, documentation: {type: 'string', desc: '最近融资'}
    expose :callreport_num, documentation: {type: 'string', desc: '最近融资'} do
      '假数据'
    end
    expose :updated_at, documentation: {type: 'datetime', desc: '最近更新时间'}

    # expose :address, with: Entities::Address, documentation: {type: 'string', desc: '地址'}
  end
end
