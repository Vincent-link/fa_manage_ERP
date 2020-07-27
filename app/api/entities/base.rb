module Entities
  class Base < Grape::Entity
    format_with(:time_to_s_date) do |dt|
      dt = Time.parse(dt) if dt.is_a? String
      dt&.to_s(:date)
    end
    format_with(:time_to_s_second) do |dt|
      dt = Time.parse(dt) if dt.is_a? String
      dt&.to_s(:second)
    end
    format_with(:time_to_s_minute) do |dt|
      dt = Time.parse(dt) if dt.is_a? String
      dt&.to_s(:minute)
    end
    format_with(:dm_time_to_s_second) {|dt| Time.parse(dt)&.to_s(:second)}
    format_with(:c_ymd_hm) {|dt| dt.to_s(:c_ymd_hm)}
  end
end
