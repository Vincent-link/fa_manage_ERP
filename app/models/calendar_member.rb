class CalendarMember < ApplicationRecord
  belongs_to :calendar
  belongs_to :memberable, polymorphic: true
end
