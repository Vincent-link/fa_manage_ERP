class CalendarMember < ApplicationRecord
  belongs_to :calendar
  belongs_to :memberable, -> {with_deleted}, polymorphic: true
  delegate :name, :position, :tel, to: :memberable, prefix: true
end
