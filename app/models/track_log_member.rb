class TrackLogMember < ApplicationRecord
  belongs_to :member
  belongs_to :track_log
end
