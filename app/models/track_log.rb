class TrackLog < ApplicationRecord
  acts_as_paranoid

  include StateConfig
  include BlobFileSupport

  has_one_attached :file_ts
  has_one_attached :file_spa

  has_blob_upload :file_ts, :file_spa

  has_many :track_log_details, -> {order(created_at: :desc)}
  has_many :calendars
  belongs_to :organization
  belongs_to :funding

  has_many :track_log_members
  has_many :members, through: :track_log_members, class_name: 'Member'

  delegate :name, :round_id, :user_names, :sector_list, to: :funding, prefix: true
  delegate :name, to: :organization, prefix: true

  state_config :status, config: {
      contacted: {value: 0, desc: "Contacted", level: 1},
      interested: {value: 1, desc: "Interested", level: 1},
      meeting: {value: 2, desc: "Meeting", level: 1},
      issue_ts: {value: 3, desc: "Issue TS", level: 2},
      spa_sha: {value: 4, desc: "SPA/SHA", level: 3},
      pass: {value: 5, desc: "Pass", level: 1},
      drop: {value: 6, desc: "Drop", level: 1}
  }

  def self.search(params)
    track_logs = self.all

    if params[:status].present?
      track_logs = track_logs.where(status: params[:status])
    end

    if params[:no_status].present?
      track_logs = track_logs.where.not(status: params[:no_status])
    end

    if params[:organization_id].present?
      track_logs = track_logs.where(organization_id: params[:organization_id])
    end

    if params[:keyword].present?
      track_logs = track_logs.joins("left join track_log_members tlm on tlm.track_log_id = track_logs.id
                                     left join members m on m.deleted_at is null and m.id = tlm.member_id
                                     left join organizations o on o.deleted_at is null and o.id = track_logs.organization_id")
                       .where("o.name ilike ? or m.name ilike ?", "%#{params[:keyword]}%", "%#{params[:keyword]}%").distinct(:id)
    end

    track_logs
  end

  def change_status_and_gen_detail(params)
    raise "此跟进记录已是#{self.status_desc}状态，不要重复变更" if self.status == params[:status].to_i
    params[:need_content] = true
    case params[:status].to_i
    when TrackLog.status_issue_ts_value
      raise '未传TS不能进行状态变更' unless (params[:file_ts] || self.file_ts).present?
      if params[:file_ts].present? && params[:file_ts][:blob_id].present?
        self.change_ts(User.current.id, params[:file_ts][:blob_id])
        params[:need_content] = false
      end
    when TrackLog.status_spa_sha_value
      [:pay_date, :is_fee, :fee_discount, :fee_rate, :amount, :ratio, :currency].each {|ins| raise '融资结算信息不全' unless params[ins].present?}
      raise '未传SPA不能进行状态变更' unless (params[:file_spa] || self.file_spa).present?
      if params[:file_spa].present? && params[:file_spa][:blob_id].present?
        self.update_spa_msg(params.slice(:pay_date, :is_fee, :fee_discount, :fee_rate, :amount, :ratio, :currency, :file_spa))
        params[:need_content] = false
      end
    when TrackLog.status_meeting_value
      if params[:calendar].present?
        User.current.created_calendars.create!(params[:calendar].slice(:started_at, :ended_at, :address_id, :meeting_type).merge(meeting_category: Calendar.meeting_category_roadshow_value, track_log_id: tracklog.id))
        params[:need_content] = false
      end
      # raise '未创建会议不能进行状态变更' unless self.calendars.present?
    when TrackLog.status_pass_value, TrackLog.status_drop_value
      content = "#{params[:content_key] || '状态变更'}：#{self.status_desc} → #{TrackLog.status_desc_for_value(params[:status])}\n#{params[:content]}"
      self.track_log_details.create(content: content, user_id: params[:user_id] || User.current.id, detail_type: TrackLogDetail.detail_type_base_value)
      params[:need_content] = false
    end
    before_status = self.status_desc
    self.update(status: params[:status])
    if params[:need_content]
      content = "#{params[:content_key] || '状态变更'}：#{before_status} → #{TrackLog.status_desc_for_value(params[:status])}"
      self.track_log_details.create(content: content, user_id: params[:user_id] || User.current.id, detail_type: TrackLogDetail.detail_type_base_value)
    end
  end

  def change_ts(user_id, blob_id, action = nil)
    case action
    when 'delete'
      self.file_ts_attachment.delete
      action = 'delete'
    else
      if self.file_ts_attachment.present?
        self.file_ts_file_only_change(blob_id: blob_id)
        action = 'update'
      else
        self.file_ts_file = {blob_id: blob_id}
        action = 'create'
      end
    end
    self.reload.gen_ts_detail(user_id, action)
  end

  def gen_meeting_detail(user_id, calendar_id, action, content = nil)
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
    when 'only_link'
      content = content
    end
    history = {
        meeting_type_desc: calendar.meeting_type_desc,
        meeting_type: calendar.meeting_type,
        started_at: calendar.started_at,
        ended_at: calendar.ended_at,
        address_id: calendar.address_id,
        address_desc: calendar.address&.address_desc,
        location_id: calendar.address&.location_id,
        province_id: CacheBox.dm_locations[calendar.address&.location_id]&.parent_id,
        status: calendar.status,
        status_desc: calendar.status_desc,
        id: calendar.id,
    }
    self.track_log_details.create!(user_id: user_id, content: content, linkable_id: calendar_id, linkable_type: 'Calendar', history: history, detail_type: TrackLogDetail.detail_type_calendar_value)
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
        members: self.members.map {|ins| {id: ins.id, name: ins.name}},
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
    self.track_log_details.create!(user_id: user_id, content: content, linkable_id: self.id, linkable_type: 'TrackLog', history: history, detail_type: TrackLogDetail.detail_type_spa_value)
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
    self.track_log_details.create!(user_id: user_id, content: content, linkable_id: self.id, linkable_type: 'TrackLog', history: history, detail_type: TrackLogDetail.detail_type_ts_value)
  end

  def update_spa_msg(params)
    [:pay_date, :is_fee, :fee_discount, :fee_rate, :amount, :ratio, :currency].each {|ins| raise '融资结算信息不全' unless (params[ins] || ins.try(ins.to_s)).present?}
    self.update!(params.slice(:pay_date, :is_fee, :fee_discount, :fee_rate, :amount, :ratio, :currency))
    if self.file_spa.present?
      self.file_spa_file_only_change(params[:file_spa]) if params[:file_spa][:blob_id].present?
      action = 'update'
    else
      self.file_spa_file = params[:file_spa]
      action = 'create'
    end
    user_id = User.current.id
    self.gen_spa_detail(user_id, action)
  end

  def change_spa(user_id, blob_id)
    if self.file_spa.present?
      self.file_spa_file_only_change(blob_id: blob_id)
      action = 'update'
    else
      self.file_spa_file = {blob_id: blob_id}
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
    self.track_log_details.create!(user_id: user_id, content: content, linkable_id: self.id, linkable_type: 'TrackLog', history: history, detail_type: TrackLogDetail.detail_type_spa_value)
  end

  def change_status_by_calendar(status)
    case status
    when 'pass'
      self.change_status_and_gen_detail(status: TrackLog.status_pass_value, need_content: true, content_key: '由约见结论变更')
    when 'continue'
      self.change_status_and_gen_detail(status: TrackLog.status_interested_value, need_content: true, content_key: '由约见结论变更')
    end
  end

  def member_names
    self.members.map(&:name).join('、')
  end

  def last_detail
    self.track_log_details.order(updated_at: :desc).first
  end
end
