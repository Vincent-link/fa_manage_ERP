class Tag < ApplicationRecord
  acts_as_taggable_on :sub_tags
end
