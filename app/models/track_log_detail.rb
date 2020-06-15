class TrackLogDetail < ApplicationRecord
  acts_as_paranoid

  include StateConfig

  belongs_to :track_log
  belongs_to :user
  belongs_to :linkable, polymorphic: true, optional: true
  # todo 多态关联需要 SPA

  state_config :detail_type, config: {
      base:     { value: 0, desc: "基础信息"  },
      document: { value: 1, desc: "上传了文件"},
      calendar: { value: 2, desc: "约见"     },
      spa:      { value: 3, desc: "SPA"     },
  }
end
