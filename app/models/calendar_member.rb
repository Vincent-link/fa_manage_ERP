class CalendarMember < ApplicationRecord
  belongs_to :calendar
  belongs_to :memberable, polymorphic: true
  delegate :name, :position, to: :memberable, prefix: true
end
