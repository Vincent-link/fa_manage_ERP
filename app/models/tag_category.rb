class TagCategory < ApplicationRecord
  acts_as_taggable_on :tags
  acts_as_taggable_on :sectors
end
