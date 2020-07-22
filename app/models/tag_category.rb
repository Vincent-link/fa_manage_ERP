class TagCategory < ApplicationRecord
  acts_as_taggable_on :tags

  after_save :update_coverage

  include StateConfig

  state_config :tag_category_type, config: {
      organization_tag: { value: 1, desc: "organization_tag" },
      company_tag: { value: 2, desc: "company_tag" },
      investor_tag: { value: 3, desc: "investor_tag" },
  }

  def tag_category_type
    TagCategory.tag_category_type_desc_for_value(self.id)
  end

  def update_coverage
    ActsAsTaggableOn::Tag.find(self.tags.last.id).update(coverage: self.id)
  end
end
