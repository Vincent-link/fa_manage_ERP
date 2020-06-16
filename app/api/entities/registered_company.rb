module Entities
  class RegisteredCompany < Base
    expose :name, documentation: {type: 'string', desc: '名称', required: true}
    expose :info_url, documentation: {type: 'string', desc: '天眼查网址', required: true}
  end
end
