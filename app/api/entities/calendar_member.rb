module Entities
  class CalendarMember < Base
    expose :id
    expose :memberable_id
    expose :memberable_name
    expose :memberable_position
  end
end