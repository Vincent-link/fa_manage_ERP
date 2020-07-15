class CalendarApi < Grape::API
  resource :calendars do
    desc '获取日程', entity: Entities::Calendar
    params do
      requires :start_date, type: Date, desc: '起始时间'
      requires :end_date, type: Date, desc: '结束时间'
      optional :organization_id, type: Integer, desc: '获取机构的日程 机构id，项目id，数据范围三选一必填'
      optional :funding_id, type: Integer, desc: '获取项目的日程 机构id，项目id，数据范围三选一必填'
      optional :range, type: String, desc: '数据范围 person个人，group含下属', values: ['person', 'group']
      at_least_one_of :organization_id, :funding_id, :range
      optional :user_id, type: Integer, desc: '获取某下属时下属id，为空返回自己'
      optional :status, type: Integer, desc: '状态'
      optional :meeting_category, type: Integer, desc: '会议类型'
    end
    get do
      cal = if params[:organization_id].present?
              Calendar.where(organization_id: params[:organization_id])
            elsif params[:funding_id].present?
              Calendar.where(funding_id: params[:funding_id])
            elsif params[:range].present?
              user = params[:user_id] ? current_user.sub_users.find(params[:user_id]) : current_user
              case params[:range]
              when 'person'
                user.calendars
              when 'group'
                Calendar.where(calendar_members: {memberable_type: 'User', memberable_id: CacheBox.get_group_user_ids(user.id)})
              end
            end
      cal = cal.where(status: params[:status]) if params[:status]
      cal = cal.where(meeting_category: params[:meeting_category]) if params[:meeting_category]
      cal = cal.where(started_at: params[:start_date]..(params[:end_date] + 1))
      present cal.includes(:user, :organization, :company, org_members: :memberable, com_members: :memberable, user_members: :memberable), with: Entities::Calendar
    end

    desc '创建日程', entity: Entities::Calendar
    params do
      requires :meeting_category, type: Integer, desc: '会议类型'
      requires :meeting_type, type: Integer, desc: '约见类型'
      given meeting_category: ->(val) {val.in?([Calendar.meeting_category_com_meeting_value, Calendar.meeting_category_roadshow_value])} do
        requires :company_id, type: Integer, desc: '约见公司id'
      end
      given meeting_category: ->(val) {val == Calendar.meeting_category_roadshow_value} do
        requires :funding_id, type: Integer, desc: '项目id'
      end
      given meeting_category: ->(val) {val.in?([Calendar.meeting_category_org_meeting_value, Calendar.meeting_category_roadshow_value])} do
        requires :organization_id, type: Integer, desc: '约见机构id'
      end
      optional :track_log_id, type: Integer, desc: '融资进度id'
      optional :desc, type: String, desc: '会议描述', default: '由项目进度生成'
      at_least_one_of :track_log_id, :desc
      optional :contact_ids, type: Array[Integer], desc: '公司联系人id'
      optional :member_ids, type: Array[Integer], desc: '投资人id'
      requires :cr_user_ids, type: Array[Integer], desc: '华兴参与人id'
      requires :started_at, type: DateTime, desc: '开始时间'
      requires :ended_at, type: DateTime, desc: '结束时间'
      optional :address_id, type: Integer, desc: '会议地点id'
      optional :tel_desc, type: String, desc: '电话会议描述'
    end
    post do
      @calendar = current_user.created_calendars.create!(declared(params, include_missing: false))
      present @calendar, with: Entities::Calendar
    end

    desc '近期会议'
    params do
      optional :organization_id, type: Integer, desc: '获取机构的日程 机构id，项目id，数据范围三选一必填'
      optional :funding_id, type: Integer, desc: '获取项目的日程 机构id，项目id，数据范围三选一必填'
      optional :range, type: String, desc: '数据范围 person个人，group含下属', values: ['person', 'group']
      optional :user_id, type: Integer, desc: '获取某下属时下属id，为空返回自己'
      optional :status, type: Integer, desc: '状态'
      optional :meeting_category, type: Integer, desc: '会议类型'
    end
    get :monthly_count do
      cal = if params[:organization_id].present?
              Calendar.where(organization_id: params[:organization_id])
            elsif params[:funding_id].present?
              Calendar.where(funding_id: params[:funding_id])
            elsif params[:range].present?
              user = params[:user_id] ? current_user.sub_users.find(params[:user_id]) : current_user
              case params[:range]
              when 'person'
                user.calendars
              when 'group'
                Calendar.includes(:calendar_members).where(calendar_members: {memberable_type: 'User', memberable_id: CacheBox.get_group_user_ids(user.id)})
              end
            end
      cal = cal.where(status: params[:status]) if params[:status]
      cal = cal.where(meeting_category: params[:meeting_category]) if params[:meeting_category]
      cal.nearly.group("cast(date_trunc('month', started_at) as Date)").count.sort_by {|k, _v| k.to_s}.map {|k, v| {start_date: k, end_date: k.end_of_month, count: v, desc: k.month}}
    end

    resource ':id' do
      desc '编辑日程', entity: Entities::Calendar
      params do
        requires :meeting_category, type: Integer, desc: '会议类型'
        requires :meeting_type, type: Integer, desc: '约见类型'
        requires :desc, type: String, desc: '会议描述'
        optional :company_id, type: Integer, desc: '约见公司id'
        optional :funding_id, type: Integer, desc: '项目id'
        optional :organization_id, type: Integer, desc: '约见机构id'
        optional :track_log_id, type: Integer, desc: '融资进度id'
        optional :desc, type: String, desc: '会议描述', default: '由项目进度生成'
        at_least_one_of :track_log_id, :desc
        optional :contact_ids, type: Array[Integer], desc: '公司联系人id', default: []
        optional :member_ids, type: Array[Integer], desc: '投资人id', default: []
        requires :cr_user_ids, type: Array[Integer], desc: '华兴参与人id'
        requires :started_at, type: DateTime, desc: '开始时间'
        requires :ended_at, type: DateTime, desc: '结束时间'
        optional :address_id, type: Integer, desc: '会议地点id'
        optional :tel_desc, type: String, desc: '电话会议描述'
      end
      patch do
        @calendar = Calendar.find params[:id]
        @calendar.update!(declared(params))
        present @calendar, with: Entities::Calendar
      end

      desc '删除日程'
      delete do
        @calendar = Calendar.find params[:id]
        @calendar.destroy!
      end

      desc '取消日程'
      post :cancel do
        calendar = Calendar.find params[:id]
        calendar.update(status: Calendar.status_cancel_value)
      end

      desc '填写纪要'
      params do
        requires :summary, type: String, desc: '纪要'
        optional :investor_summary, type: JSON, desc: '投资人信息更新 investor_summary[member_id] = xxxxx'
        optional :ir_review_syn, type: Boolean, desc: '是否同步到IR Review'
        optional :newsfeed_syn, type: Boolean, desc: '是否同步到Newsfeed'
        optional :track_result, type: String, desc: 'track_log跟进', values: %w(continue pass)
      end
      post :summary do
        calendar = Calendar.find params[:id]
        calendar.update! declared(params)
        present calendar, with: Entities::Calendar
      end

      desc '清空会议纪要'
      delete :summary do
        calendar = Calendar.find params[:id]
        calendar.update! summary: nil
        present calendar, with: Entities::Calendar
      end

      desc '约见详情'
      get do
        @calendar = Calendar.find params[:id]
        present @calendar, with: Entities::CalendarForShow
      end
    end
  end
end