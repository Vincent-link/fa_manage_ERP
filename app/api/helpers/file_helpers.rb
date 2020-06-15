module Helpers
  module FileHelpers
    def auth_type(type)
      raise '上传类型错误' unless FileType.upload_type.values.include? type
    end
  end
end