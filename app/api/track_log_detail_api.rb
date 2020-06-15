class TrackLogDetailApi < Grape::API
  resource :track_logs do
    resource ':id' do
      before do
        @track_log = TrackLog.find params[:id]
      end

      resource :track_log_details do
        desc '新增跟进信息', entity: Entities::TrackLogDetail
        params do
          optional :content, type: String, desc: '跟进信息'
          optional :calendar_id, type: Integer, desc: '约见id'
        end

        post do
          params = declared(params)
          if params[:calendar_id].present?
            @track_log.calendars.find params[:calendar_id]
            params[:linkable_id] = params[:calendar_id]
            params[:linkable_type] = 'Calendar'
          end
          @track_log.track_log_details.create(params.slice(:content).merge(user_id: current_user.id, detail_type: TrackLogDetail.detail_type_base_value))
          track_log_details = @track_log.track_log_details.includes(:linkable)
          present track_log_details, with: Entities::TrackLogDetail
        end

        desc '跟进信息列表', entity: Entities::TrackLogDetail
        params do
          optional :calendar_id, type: Integer, desc: '约见id'
        end

        get do
          track_log_details = @track_log.track_log_details.includes(:linkable)
          track_log_details = track_log_details.where(linkable_id: calendar_id, linkable_type: 'Calendar') if params[:calendar_id].present?
          present track_log_details, with: Entities::TrackLogDetail
        end
      end
    end
  end
end
