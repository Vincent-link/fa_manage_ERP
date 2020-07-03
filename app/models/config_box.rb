class ConfigBox
  include StateConfig

  state_config :upload_type, config: {
      organization_logo:        { value: 'organization_logo', desc: "机构logo"  , is_static: true},
      member_logo:              { value: 'member_logo',       desc: "投资人logo", is_static: true},
      company_logo:             { value: 'company_logo',      desc: "公司logo",   is_static: true},
      knowledge_base_file:      { value: 'knowledge_base_file',      desc: "知识库文件",   is_static: false},
      member_avatar:            { value: 'member_avatar',       desc: "投资人头像", is_static: true},
      member_card:            { value: 'member_card',       desc: "投资人名片", is_static: false},
  }
end
