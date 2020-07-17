module Entities
  class CalendarMember < Base
    expose :id
    expose :memberable_id
    expose :memberable_name
    expose :memberable_type
    expose :memberable_position
    expose :ir_review do |ins|
      if ins.calendar.meeting_category_org_meeting?
        ins.memberable.ir_review if ins.memberable.is_a? Member
      end
    end
  end
end