class OrganizationTag < ApplicationRecord
  belongs_to :organization_tag_category

  def organization_num
    Organization.where("'#{self.id}' = ANY (tag_ids)").count
  end
end