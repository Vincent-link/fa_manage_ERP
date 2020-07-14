class EmailBlob < ApplicationRecord
  belongs_to :email
  belongs_to :blob, class_name: "ActiveStorage::Blob", foreign_key: :blob_id, optional: true

  include StateConfig

  state_config :file_kind, config: {
      water:      { value: 1, desc: "水印附件"  },
      no_water:   { value: 2, desc: "无水印附件"},
      link:       { value: 3, desc: "共享链接"  },
  }
end
