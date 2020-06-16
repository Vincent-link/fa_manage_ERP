class TagCategory < ApplicationRecord
  acts_as_taggable_on :tags

  include StateConfig

  state_config :tag_category_type, config: {
      organization_tag: { value: 1, desc: "机构标签" },
      company_tag: { value: 2, desc: "公司标签" },
      sector: { value: 3, desc: "行业标签" },
      investor_tag: { value: 4, desc: "投资人标签" },
  }

end
