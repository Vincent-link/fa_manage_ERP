module Entities
  class CalendarForShow < Calendar
    expose :track_log_details, using: Entities::TrackLogDetail, documentation: {type: Entities::TrackLogDetail, desc: '关联的track_log跟进'}
    expose :result_track_log_detail, using: Entities::TrackLogDetail, documentation: {type: Entities::TrackLogDetail, desc: '结论的track_log跟进'}
  end
end