module Entities
  class UserForFundingUser < User
    expose :is_current_bu, documentation: {type: 'boolean', desc: '是否为当前BU成员'}
    expose :bu_id, documentation: {type: 'integer', desc: 'bu_id'}
    expose :bu_name, documentation: {type: 'string', desc: 'bu_name'}
  end
end
