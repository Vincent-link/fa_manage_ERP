module Entities
  class Bsc < Base
    expose :investment_committee_opinion, documentation: {type: 'string', desc: '投委会观点', required: true}
    expose :project_team_opinion, documentation: {type: 'string', desc: '项目组观点', required: true}
  end
end
