class CommonApi < Grape::API
  resource :common do
    desc '字典'
    get :dict do
      {
          sector_tree: CacheBox.dm_sector_tree,
          root_sector: CacheBox.dm_root_sector,
          rounds: CacheBox.dm_rounds,
          org_level: Organization.level_id_name,
          currencies: CacheBox.dm_currencies,
          locations: CacheBox.dm_location_tree,
          member_locations: CacheBox.dm_member_location,
          org_tier: Organization.tier_id_name,
          member_report_type: Member.report_type_id_name,
          member_position_rank: CacheBox.dm_position_ranks,
          org_invest_period: Organization.invest_period_id_name,
          org_nature: Organization.org_nature_id_name,
          member_scale: Member.scale_id_name,
          calendar_meeting_type: Calendar.meeting_type_id_name,
          calendar_meeting_category: Calendar.meeting_category_id_name,
          calendar_status: Calendar.status_id_name,
          funding_contact_position: FundingCompanyContact.position_id_id_name,
          funding_status: Funding.status_id_name,
          funding_category: Funding.category_id_name,
          funding_source_type: Funding.source_type_id_name,
          funding_confidentiality_level: Funding.confidentiality_level_id_name(:full_desc),
          track_log_detail_detail_type: TrackLogDetail.detail_type_id_name(:key),
          pipeline_status: Pipeline.status_id_name(:rate),
          track_log_status: TrackLog.status_id_name,
          funding_all_funding_file_type: Funding.all_funding_file_type_id_name,
          email_blob_file_kind: EmailBlob.file_kind_id_name,
          email_signature_template: Email.signature_template_id_name,
          email_email_template: Email.email_template_id_name,
          email_emailable_type: Email.emailable_type_id_name,
          email_status: Email.status_id_name,
          funding_type_range: Funding.type_range_id_name,
          config_box_upload_type: ConfigBox.upload_type_id_name,
          teams: Team.all.select(:id, :name).as_json
      }
    end

    desc '顶部搜索（假）'
    get :head_search do

    end

    desc '实时汇率USD/RMB'
    get :current_currency do
      {
          usd_rmb: ConfigBox.rmb_usd_rate
      }
    end
  end
end