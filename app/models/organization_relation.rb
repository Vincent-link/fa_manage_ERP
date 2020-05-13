class OrganizationRelation < ApplicationRecord
  include StateConfig

  belongs_to :organization
  belongs_to :relation_organization, class_name: 'Organization'

  state_config :relation_type, config: {
      lead: {value: 1, desc: '上级机构'},
      mate: {value: 2, desc: '同级机构'},
  }
end
