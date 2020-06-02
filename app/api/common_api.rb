class CommonApi < Grape::API
  resource :common do
    desc '字典'
    get :dict do
      {
          sector_tree: CacheBox.dm_sector_tree,
          rounds: CacheBox.dm_rounds,
          org_level: Organization.level_id_name,
          currencies: CacheBox.dm_currencies,
          locations: CacheBox.dm_locations,
          org_tier: Organization.tier_id_name,
          member_report_type: Member.report_type_id_name,
          member_position_rank: CacheBox.dm_position_ranks,
          org_invest_period: Organization.invest_period_id_name,
          org_nature: Organization.org_nature_id_name,
          member_scale: Member.scale_id_name,
          calendar_meeting_type: Calendar.meeting_type_id_name,
          calendar_meeting_category: Calendar.meeting_category_id_name,
          funding_contact_position: FundingCompanyContact.position_id_id_name,
          funding_status: Funding.status_id_name,
          funding_categroy: Funding.categroy_id_name,
      }
    end

    desc 'oss upload url'
    params do
      requires :is_static, type: Boolean, desc: '是否静态文件', default: false
      optional :upload_type, type: String, desc: '上传类型', values: ['organization_logo', 'member_logo']
    end
    get :oss_upload_url do
      s = Aws::S3::Presigner.new
      bucket = params[:is_static] ? 'arrow-fa' : 'arrow-fa'
      key = case params[:upload_type]
            when 'organization_logo'
              'organizations/logo'
            when 'member_logo'
              'members/logo'
            else
              'temp'
            end
      key = "#{key}/#{SecureRandom.hex(32)}"
      url = s.presigned_url :put_object, bucket: bucket, key: key
      {
          url: url,
          path: "#{bucket}/#{key}"
      }
    end

    desc '顶部搜索（假）'
    get :head_search do

    end
  end
end