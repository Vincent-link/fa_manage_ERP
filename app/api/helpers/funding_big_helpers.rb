module Helpers
  module FundingBigHelpers
    def auth_funding_code(params)
      raise '项目类型选择错误' unless Funding.values.include? params[:categroy]

      error_msg = []
      Funding.categroy_value_code(params[:categroy], :code)&.each do |code|
        error_msg << I18n.t(code.to_s ,scope: [:activerecord, :attributes, :funding]) unless params[code].present?
      end
      raise "#{error_msg.join('、')} 未填" if error_msg.present?
    end
  end
end