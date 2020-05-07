module Entities
  class DmMemberReportRelation < Base
    expose :id, documentation: {type: 'integer', desc: '汇报关系id'}
    expose :member_id, documentation: {type: 'integer', desc: '投资人id'}
    expose :superior_id, documentation: {type: 'integer', desc: '上级投资人id'}
    expose :report_type, documentation: {type: 'integer', desc: '汇报关系类型'}
  end
end