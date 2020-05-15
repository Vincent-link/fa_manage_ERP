module Entities
  class OrganizationForSelect < Base
    expose :id, documentation: {type: 'integer', desc: '机构id', required: true}
    expose :name, documentation: {type: 'string', desc: '机构名称', required: true}
    expose :level, documentation: {type: 'string', desc: '机构级别'}
    expose :logo, using: Entities::File,if: ->(ins) {ins.logo.present?}, documentation: {type: Entities::File, desc: '机构logo'}
  end
end