class OrganizationTagCategory < ApplicationRecord
  has_many :organization_tags, dependent: :destroy
end
