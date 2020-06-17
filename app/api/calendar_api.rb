class CalendarApi < Grape::API
  resource :calendars do
    desc '获取日程', entity: Entities::Calendar
    params do
      requires :start_date, type: Date, desc: '起始时间'
      requires :end_date, type: Date, desc: '结束时间'
      requires :range, type: String, desc: '数据范围 person个人，group含下属', values: ['person', 'group']
      optional :user_id, type: Integer, desc: '获取某下属时下属id，为空返回自己'
      optional :status, type: Integer, desc: '状态'
      optional :meeting_category, type: Integer, desc: '会议类型'
    end
    get do
      user = params[:user_id] ? current_user.sub_users.find(params[:user_id]) : current_user
      cal = case params[:range]
            when 'person'
              user.calendars
            when 'group'
              Calendar.includes(:calendar_members).where(calendar_members: {memberable_type: 'User', memberable_id: CacheBox.get_group_user_ids(user.id)})
            end
      cal = cal.where(status: params[:status]) if params[:status]
      cal = cal.where(meeting_category: params[:meeting_category]) if params[:meeting_category]
      cal = cal.where(started_at: params[:start_date]..params[:end_date])
      present cal, with: Entities::Calendar
    end

    desc '创建日程', entity: Entities::Calendar
    params do
      requires :meeting_category, type: Integer, desc: '会议类型'
      requires :meeting_type, type: Integer, desc: '约见类型'
      requires :desc, type: String, desc: '会议描述'
      optional :company_id, type: Integer, desc: '约见公司id'
      optional :funding_id, type: Integer, desc: '项目id'
      optional :organization_id, type: Integer, desc: '约见机构id'
      optional :company_contact_ids, type: Array[Integer], desc: '公司联系人id'
      optional :member_ids, type: Array[Integer], desc: '投资人id'
      requires :cr_user_ids, type: Array[Integer], desc: '华兴参与人id'
      requires :started_at, type: DateTime, desc: '开始时间'
      requires :ended_at, type: DateTime, desc: '结束时间'
      optional :address_id, type: Integer, desc: '会议地点id'
    end
    post do
      @calendar = current_user.created_calendars.create!(declared(params, include_missing: false))
      present @calendar, with: Entities::Calendar
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
        optional :company_contact_ids, type: Array[Integer], desc: '公司联系人id'
        optional :member_ids, type: Array[Integer], desc: '投资人id'
        requires :cr_user_ids, type: Array[Integer], desc: '华兴参与人id'
        requires :started_at, type: DateTime, desc: '开始时间'
        requires :during, type: Integer, desc: '持续时间（分钟）'
        optional :address_id, type: Integer, desc: '会议地点id'
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

      desc '填写纪要'
      params do
        requires :summary, type: String, desc: '纪要'
        optional :investor_summary, type: JSON, desc: '投资人信息更新 investor_summary[member_id] = xxxxx'
        optional :ir_review_syn, type: Boolean, desc: '是否同步到IR Review'
        optional :newsfeed_syn, type: Boolean, desc: '是否同步到Newsfeed'
      end
      post :summary do
        @calendar = Calendar.find params[:id]
        @calendar.update! summary: params[:summary]
        present @calendar, with: Entities::Calendar
      end

      desc '约见详情'
      get do
        @calendar = Calendar.find params[:id]
        present @calendar, with: Entities::Calendar
      end
    end
  end
end