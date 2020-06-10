class TrackLog < ApplicationRecord
  acts_as_paranoid

  include StateConfig

  has_one_attached :file_ts
  has_one_attached :file_spa
  has_many_attached :file_histories

  has_many :track_log_details, -> {order(created_at: :desc)}
  belongs_to :organization
  belongs_to :funding

  has_many :track_log_members
  has_many :members, through: :track_log_members, class_name: 'Member'

  state_config :status, config: {
      contacted:    { value: 0, desc: "Contacted" , level: 1 },
      interested:   { value: 1, desc: "Interested", level: 1 },
      meeting:      { value: 2, desc: "Meeting"   , level: 1 },
      issue_ts:     { value: 3, desc: "Issue TS"  , level: 2 },
      spa_sha:      { value: 4, desc: "SPA/SHA"   , level: 3 },
      pass:         { value: 5, desc: "Pass"      , level: 1 },
      drop:         { value: 6, desc: "Drop"      , level: 1 }
  }

  def search(params)
    track_logs = self.all

    if params[:status].present?
      track_logs = track_logs.where(status: params[:status])
    end

    if params[:keyword].present?
      track_logs = track_logs.joins("left join track_log_members tlm on tlm.track_log_id = track_logs.id
                                     left join members m on m.deleted_at is null and m.id = tlm.member_id
                                     left join organizations o on o.deleted_at is null and o.id = track_logs.organization_id")
                       .where("o.name ilike ? or m.name ilike ?", "%#{params[:keyword]}%", "%#{params[:keyword]}%")
    end

    track_logs
  end

  def change_status_and_gen_detail(params)
    raise "此跟进记录已是#{self.status_desc}状态，不要重复变更" if self.status == params[:status].to_i
    case params[:status].to_i
    when TrackLog.status_issue_ts_value
      raise '未传TS不能进行状态变更' unless self.file_ts.present?
    when TrackLog.status_spa_sha_value
      raise '未传SPA不能进行状态变更' unless 1 # todo 融资结算详情还没有
    end

    content = "状态变更：#{self.status_desc} → #{TrackLog.status_desc_for_value(params[:status.to_i])}"
    self.update(status: params[:status])
    self.track_log_details.create(content: content, user_id: params[:user_id], detail_type: TrackLogDetail.detail_type_base_value)
  end
end
