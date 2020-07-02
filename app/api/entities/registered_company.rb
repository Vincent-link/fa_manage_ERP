module Entities
  class RegisteredCompany < Base
    expose :id, documentation: {type: 'string', desc: 'id', required: true}
    expose :name, documentation: {type: 'string', desc: '名称', required: true}
    expose :info_url, documentation: {type: 'string', desc: '天眼查网址', required: true}
    expose :address, documentation: {type: 'string', desc: '地址', required: true}
    expose :artificial_person, documentation: {type: 'string', desc: '法人代表', required: true}
  end
end
