class EmailTo < ApplicationRecord
  belongs_to :email_to_group
  belongs_to :toable, polymorphic: true
end
