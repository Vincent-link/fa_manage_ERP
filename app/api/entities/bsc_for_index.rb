module Entities
  class BscForIndex < Base
    expose :id, documentation: {type: 'integer', desc: '项目id'}
    expose :name, documentation: {type: 'string', desc: '项目名称'}
    expose :bsc_status, documentation: {type: 'string', desc: "bsc状态", required: true} do |ins|
      {
          id: ins.bsc_status,
          name: ins.bsc_status_config[:zh_desc]
      }
    end
    expose :evaluations, using: Entities::Evaluation
    expose :conference_team, using: Entities::OrganizationTeam
  end
end
