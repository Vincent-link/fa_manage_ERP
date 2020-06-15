class TrackLog < ApplicationRecord
  acts_as_paranoid

  include StateConfig

  has_one_attached :file_ts
  has_one_attached :file_spa

  has_many :track_log_details, -> { order(created_at: :desc) }
  has_many :calendars
  belongs_to :organization
  belongs_to :funding

  has_many :track_log_members
  has_many :members, through: :track_log_members, class_name: 'Member'

  state_config :status, config: {
      contacted:   {value: 0, desc: "Contacted",   level: 1},
      interested:  {value: 1, desc: "Interested",  level: 1},
      meeting:     {value: 2, desc: "Meeting",     level: 1},
      issue_ts:    {value: 3, desc: "Issue TS",    level: 2},
      spa_sha:     {value: 4, desc: "SPA/SHA",     level: 3},
      pass:        {value: 5, desc: "Pass",        level: 1},
      drop:        {value: 6, desc: "Drop",        level: 1}
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
    params[:need_content] = true
    case params[:status].to_i
    when TrackLog.status_issue_ts_value
      raise '未传TS不能进行状态变更' unless (params[:file_ts] || self.file_ts).present?
      if params[:file_spa].present? && params[:file_spa][:blob_id].present?
        self.change_ts(current_user.id, params[:file_spa][:blob_id])
        params[:need_content] = false
      end
    when TrackLog.status_spa_sha_value
      [:pay_date, :is_fee, :fee_discount, :fee_rate, :amount, :ratio, :currency].each{|ins| raise '融资结算信息不全' unless params[ins].present?}
      raise '未传SPA不能进行状态变更' unless (params[:file_spa] || self.file_spa).present?
      if params[:file_spa].present? && params[:file_spa][:blob_id].present?
        self.funding.change_spas(User.current.id, {spas: [params.slice(:pay_date, :is_fee, :fee_discount, :fee_rate, :amount, :ratio, :currency, :file_spa).merge(action: 'update', id: self.id)]})
        params[:need_content] = false
      end
    when TrackLog.status_meeting_value
      if params[:calendar].present?
        User.current.created_calendars.create!(params[:calendar].slice(:started_at, :ended_at, :address_id, :meeting_type).merge(meeting_category: Calendar.meeting_category_roadshow_value, track_log_id: tracklog.id))
        params[:need_content] = false
      end
      raise '未创建会议不能进行状态变更' unless self.calendars.present?
    end
    self.update(status: params[:status])
    if params[:need_content]
      content = "状态变更：#{self.status_desc} → #{TrackLog.status_desc_for_value(params[:status.to_i])}"
      self.track_log_details.create(content: content, user_id: params[:user_id], detail_type: TrackLogDetail.detail_type_base_value)
    end
  end

  def change_ts(user_id, blob_id, action = nil)
    case action
    when 'delete'
      self.file_ts_attachment.delete
      action = 'delete'
    else
      if self.file_ts_attachment.present?
        self.file_ts_attachment.update(blob_id: blob_id)
        action = 'update'
      else
        ActiveStorage::Attachment.create!(name: 'file_ts', record_type: 'TrackLog', record_id: self.id, blob_id: params[:file_spa][:blob_id])
        action = 'create'
      end
    end
    self.gen_ts_detail(user_id, action)
  end

  def gen_meeting_detail(user_id, calendar_id, action)
    calendar = Calendar.find calendar_id
    case action
    when 'create'
      content = '安排了会议'
    when 'update'
      content = '修改了会议'
    when 'delete'
      content = '取消了会议'
    when 'finish'
      content = calendar.summary
    end
    history = {
        meeting_type_desc: calendar.meeting_type_desc,
        meeting_type: calendar.meeting_type,
        started_at: calendar.started_at,
        ended_at: calendar.ended_at,
        address_id: calendar.address_id,
        address_desc: calendar.address.address_desc,
        status: calendar.status,
        status_desc: calendar.status_desc,
        id: calendar.id,
    }
    self.track_log_details.create!(user_id: user_id, content: content, linkable_id: calendar_id, linkable_type: 'Calendar', history: history)
  end

  def gen_spa_detail(user_id, action)
    case action
    when 'create'
      content = '填写了融资结算详情'
    when 'update'
      content = '修改了融资结算详情'
    when 'delete'
      content = '删除了融资结算详情'
    end
    history = {
        id: self.id,
        organization: {
            id: self.organization_id,
            name: self.organization.name
        },
        members: self.members.map{|ins| {id: ins.id, name: ins.name}},
        amount: self.amount,
        currency: self.currency,
        ratio: self.ratio,
        pay_date: self.pay_date,
        is_fee: self.is_fee,
        fee_rate: self.fee_rate,
        fee_discount: self.fee_discount,
        file_spa: {
            blob_id: self.file_spa.blob.id,
            filename: self.file_spa.blob.filename,
            service_url: self.file_spa.blob.service_url,
        }
    }
    self.track_log_details.create!(user_id: user_id, content: content, linkable_id: self.id, linkable_type: 'TrackLog', history: history)
  end

  def gen_ts_detail(user_id, action)
    case action
    when 'create'
      content = '上传了TS'
    when 'update'
      content = '更新了TS'
    when 'delete'
      content = '删除了TS'
    end
    history = {
        id: self.id,
        file_ts: {
            blob_id: self.file_ts.blob.id,
            filename: self.file_ts.blob.filename,
            service_url: self.file_ts.blob.service_url,
        }
    }
    self.track_log_details.create!(user_id: user_id, content: content, linkable_id: self.id, linkable_type: 'TrackLog', history: history)
  end

  def change_spa(user_id, blob_id)
    if self.file_spa.present?
      self.file_spa_attachment.update(blob_id: blob_id)
      action = 'update'
    else
      ActiveStorage::Attachment.create!(name: 'file_spa', record_type: 'TrackLog', record_id: self.id, blob_id: blob_id)
      action = 'create'
    end
    self.gen_file_spa_detail(user_id, action)
  end

  def gen_file_spa_detail(user_id, action)
    case action
    when 'create'
      content = '上传了SPA文档'
    when 'update'
      content = '更新了SPA文档'
    end
    history = {
        id: self.id,
        organization: {
            id: nil,
            name: nil
        },
        members: [],
        amount: nil,
        currency: nil,
        ratio: nil,
        pay_date: nil,
        is_fee: nil,
        fee_rate: nil,
        fee_discount: nil,
        file_spa: {
            blob_id: self.file_spa.blob.id,
            filename: self.file_spa.blob.filename,
            service_url: self.file_spa.blob.service_url,
        }
    }
    self.track_log_details.create!(user_id: user_id, content: content, linkable_id: self.id, linkable_type: 'TrackLog', history: history)
  end
end
