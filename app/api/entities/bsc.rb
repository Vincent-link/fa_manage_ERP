module Entities
  class Bsc < Base
    expose :bsc_status, documentation: {type: 'string', desc: "bsc状态", required: true}
    expose :evaluations, using: Entities::Evaluation
    expose :conference_team, using: Entities::OrganizationTeam
    expose :investment_committee_opinion, documentation: {type: 'string', desc: '投委会观点', required: true}
    expose :project_team_opinion, documentation: {type: 'string', desc: '项目组观点', required: true}
  end
end
