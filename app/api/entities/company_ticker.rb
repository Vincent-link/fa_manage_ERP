module Entities
  class CompanyTicker < Base
    expose :name, documentation: {type: 'string', desc: '公司名称'}
    expose :ticker, documentation: {type: 'string', desc: '股票代码'}
  end
end
