class Company < ApplicationRecord
  has_many :calendars

  acts_as_taggable_on :tags
end
