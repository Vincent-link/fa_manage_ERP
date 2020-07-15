class ConfigBox
  include StateConfig

  state_config :upload_type, config: {
      organization_logo:        { value: 'organization_logo',     desc: "机构logo"  ,  is_static: true},
      member_logo:              { value: 'member_logo',           desc: "投资人logo",  is_static: true},
      company_logo:             { value: 'company_logo',          desc: "公司logo",    is_static: true},
      knowledge_base_file:      { value: 'knowledge_base_file',   desc: "知识库文件",   is_static: false},
      member_avatar:            { value: 'member_avatar',         desc: "投资人头像",   is_static: true},
      member_card:              { value: 'member_card',           desc: "投资人名片",   is_static: false},
      funding_file_el:          { value: 'funding_file_el',       desc: "项目EL",      is_static: false},
      funding_file_bp:          { value: 'funding_file_bp',       desc: "项目BP",      is_static: false},
      funding_file_materials:   { value: 'funding_file_materials',desc: "项目附件",     is_static: false},
      funding_file_teaser:      { value: 'funding_file_teaser',   desc: "项目TEASER",  is_static: false},
      funding_file_nda:         { value: 'funding_file_nda',      desc: "项目NDA",     is_static: false},
      funding_file_model:       { value: 'funding_file_model',    desc: "项目MODEL",   is_static: false},
      track_log_file_ts:        { value: 'track_log_file_ts',     desc: "项目进度TS",   is_static: false},
      track_log_file_spa:       { value: 'track_log_file_spa',    desc: "项目进度SPA",  is_static: false},
      email_email_extras:       { value: 'email_email_extras',    desc: "邮件附加的附件",is_static: false},
  }

  def self.rmb_usd_rate
    7
  end
end
