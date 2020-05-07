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
      }
    end

    desc '顶部搜索（假）'
    get :head_search do

    end
  end
end