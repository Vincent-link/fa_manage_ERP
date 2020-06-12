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
        end

        post do
          @track_log.track_log_details.create(params.slice(:content).merge(user_id: current_user.id, detail_type: TrackLogDetail.detail_type_base_value))
          track_log_details = @track_log.track_log_details.includes(:linkable)
          present track_log_details, with: Entities::TrackLogDetail
        end

        desc '跟进信息列表', entity: Entities::TrackLogDetail
        params do
        end

        get do
          track_log_details = @track_log.track_log_details.includes(:linkable)
          present track_log_details, with: Entities::TrackLogDetail
        end
      end
    end
  end
end
