class TrackLogDetail < ApplicationRecord
  acts_as_paranoid

  include StateConfig

  belongs_to :track_log
  belongs_to :user
  belongs_to :linkable, polymorphic: true, optional: true
  # todo 多态关联需要 SPA

  state_config :detail_type, config: {
      base:     { value: 1, desc: "基础信息"  },
      ts:       { value: 2, desc: "TS"      },
      calendar: { value: 3, desc: "约见"     },
      spa:      { value: 4, desc: "SPA"     },
      calendar_result: { value: 5, desc: "约见结论"}
  }
end
