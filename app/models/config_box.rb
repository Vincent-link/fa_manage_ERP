class ConfigBox
  include StateConfig

  state_config :upload_type, config: {
      organization_logo: { value: 'organization_logo', desc: "机构logo"   },
      member_logo:       { value: 'member_logo',       desc: "投资人logo" }
  }
end