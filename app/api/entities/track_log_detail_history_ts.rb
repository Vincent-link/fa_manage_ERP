module Entities
  class TrackLogDetailHistoryTs < Base
    expose :id, documentation: {type: 'integer', desc: 'TrackLog id'}
    expose :file_ts, using: Entities::BlobFile, documentation: {type: Entities::BlobFile, desc: 'TS文件'}
  end
end