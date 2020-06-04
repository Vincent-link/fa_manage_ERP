class Company < ApplicationRecord
  has_many :calendars

  acts_as_taggable_on :tags
  acts_as_taggable_on :sub_tags
end
