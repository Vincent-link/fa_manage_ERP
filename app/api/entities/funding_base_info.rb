module Entities
  class FundingBaseInfo < Base
    expose :id, documentation: {type: 'integer', desc: '项目id'}
    expose :name, documentation: {type: 'string', desc: '项目名称'}
    expose :status, documentation: {type: 'Entities::IdName', desc: '状态'} do |ins|
      {
          id: ins.status,
          name: ins.status_desc
      }
    end
    expose :shiny_word, documentation: {type: 'string', desc: '一句话两点'}
    expose :category, documentation: {type: 'Entities::IdName', desc: '项目类型'} do |ins|
      {
          id: ins.category,
          name: ins.category_desc
      }
    end
    expose :round_id, documentation: {type: 'integer', desc: '轮次'}
    with_options(format_with: :time_to_s_date) do
      expose :operating_day, documentation: {type: 'string', desc: '状态开始时间'}
    end
    expose :normal_users, with: Entities::User, documentation: {type: 'Entities::User', desc: '项目成员', is_array: true}
    expose :company, with: Entities::CompanyBaseInfo, documentation: {type: 'Entities::CompanyBaseInfo', desc: '公司信息'}
    expose :target_amount, documentation: {type: 'float', desc: '交易金额'}
    expose :bsc_status, documentation: {type: 'Entities::IdName', desc: 'BSC状态'} do |ins|
      {
          id: ins.bsc_status,
          name: ins.bsc_status_desc
      }
    end
    expose :has_ka_verification, documentation: {type: 'boolean', desc: '是否申请了ka'} do |ins|
      has_ka_verification = false
      ins.verifications.each do |verification|
        if verification.verification_type == 'Verification'.constantize.verification_type_funding_ka_value && verification.status.nil?
          has_ka_verification = true
          break
        end
      end
      has_ka_verification
    end
    expose :tf_search_highlights, as: :search_highlights, documentation: {type: 'hash', desc: 'es结果高亮'}
  end
end