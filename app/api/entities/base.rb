module Entities
  class Base < Grape::Entity
    format_with(:time_to_s_date) {|dt| dt&.to_s(:date)}
    format_with(:time_to_s_second) {|dt| dt&.to_s(:second)}
    format_with(:time_to_s_minute) {|dt| dt&.to_s(:minute)}
    format_with(:dm_time_to_s_second) {|dt| Time.parse(dt)&.to_s(:second)}
  end
end
