module Entities
  class UserFundingStatusSort < Base
    expose :id, documentation: {type: 'integer', desc: '用户id'}
    expose :funding_status_sort, documentation: {type: 'integer', desc: '状态排序', is_array: true} do |ins|
      ins.funding_status_sort || 'Funding'.constantize.status_values
    end
  end
end