module Helpers
  module FundingBigHelpers
    def auth_funding_code(params)
      raise '项目类型选择错误' unless Funding.category_values.include? params[:category]

      error_msg = []
      Funding.category_value_code(params[:category], :code)&.each do |code|
        error_msg << I18n.t(code.to_s ,scope: [:activerecord, :attributes, :funding]) unless params[code].present?
      end
      raise "#{error_msg.join('、')} 未填" if error_msg.present?

      if params[:funding_score].present?
        raise '评分区间错误' unless Array(1..5).include? params[:funding_score].to_i
      end
    end
  end
end