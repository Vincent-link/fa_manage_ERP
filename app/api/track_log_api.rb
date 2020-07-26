class TrackLogApi < Grape::API

  resource :fundings do
    resource ':id' do
      before do
        @funding = Funding.find params[:id]
      end

      resource :track_logs do
        desc '变更spa', entity: Entities::TrackLogBase
        params do
          optional :spas, type: Array[JSON] do
            requires :action, type: String, desc: "动作，没有变化：keep, 删除：delete，新建：create， 修改：update"
            optional :id, type: Integer, desc: "track_log_id"
            requires :pay_date, type: String, desc: '结算日期', regexp: /^\d{4}-\d{2}$/
            requires :is_fee, type: Boolean, desc: '是否收费'
            requires :fee_rate, type: Float, desc: '费率'
            requires :fee_discount, type: Float, desc: '费率折扣'
            requires :amount, type: Float, desc: '投资金额'
            requires :currency, type: Integer, desc: '币种'
            requires :ratio, type: Float, desc: '股份比例'
            given action: ->(val) {val == 'create'} do
              requires :organization_id, type: Integer, desc: '机构id'
              optional :member_ids, type: Array[Integer], desc: '投资人id'
            end
            requires :file_spa, type: Hash do
              optional :blob_id, type: Integer, desc: '重新上传的spa文件id'
              optional :id, type: Integer, desc: 'spa_id'
            end
            # requires :syn_pipeline, type: Boolean, desc: '是否同步到pipeline'
          end
          optional :pipeline_id, type: Integer, desc: '同步的pipeline_id'
          optional :est_amount, type: Float, desc: '同步金额总数'
        end

        post 'spa' do
          @funding.change_spas(current_user.id, params)
          spas = @funding.spas
          if params[:pipeline_id].present?
            raise '同步pipeline需要勾选spa' unless params[:est_amount].present?
            pipeline = @funding.pipelines.find params[:pipeline_id]
            pipeline.update!(est_amount: params[:est_amount])
          end
          present spas, with: Entities::TrackLogBase
        end

        desc '新增项目进度', entity: Entities::TrackLogBase
        params do
          requires :organization_id, type: Integer, desc: '机构id'
          optional :member_ids, type: Array[Integer], desc: '投资人id'
          optional :status, type: Integer, desc: '项目进度状态'
          optional :has_bp, type: Boolean, desc: '是否上传了bp'
          optional :has_teaser, type: Boolean, desc: '是否上传了teaser'
          optional :has_nda, type: Boolean, desc: '是否上传了nda'
          optional :has_model, type: Boolean, desc: '是否上传了model'
          optional :content, type: String, desc: '跟进信息'
          optional :track_log_id, type: Integer, desc: '合并到另一条项目进度的项目进度id'
          given status: ->(val) {val == TrackLog.status_issue_ts_value} do
            requires :file_ts, type: Hash do
              optional :blob_id, type: Integer, desc: 'ts文件id'
            end
          end

          given status: ->(val) {val == TrackLog.status_spa_sha_value} do
            given track_log_id: ->(val) {val.nil?} do
              requires :pay_date, type: String, desc: '结算日期', regexp: /^\d{4}-\d{2}$/
              requires :is_fee, type: Boolean, desc: '是否收费'
              requires :fee_rate, type: Float, desc: '费率'
              requires :fee_discount, type: Float, desc: '费率折扣'
              requires :amount, type: Float, desc: '投资金额'
              requires :currency, type: Integer, desc: '币种'
              requires :ratio, type: Float, desc: '股份比例'
              requires :file_spa, type: Hash do
                optional :blob_id, type: Integer, desc: 'spa文件id'
              end
            end
          end

          optional :calendar, type: Hash do
            requires :started_at, type: Time, desc: '开始时间'
            requires :ended_at, type: Time, desc: '结束时间'
            optional :address_id, type: Integer, desc: '会议地点id'
            requires :meeting_type, type: Integer, desc: '约见类型'
          end
        end

        post do
          # raise '项目进度状态选择错误' if params[:calendar].present? && params[:track_log_id].nil? && params[:status] != TrackLog.status_meeting_value
          organziation = Organization.find(params[:organization_id])
          params[:member_ids] = organziation.members.where(id: params[:member_ids]).map(&:id)
          if params[:track_log_id].present?
            tracklog = @funding.track_logs.find(params[:track_log_id])
            raise '此项目进度的机构与添加投资人的机构不是同一机构' if tracklog.organization_id != params[:organization_id]
            tracklog.update(status: TrackLog.status_meeting_value) if params[:calendar].present? && tracklog.status_contacted?
            params[:member_ids] |= tracklog.member_ids
          else
            tracklog = @funding.track_logs.create(params.slice(:status, :organization_id, :has_bp, :has_teaser, :has_nda, :has_model))
            case params[:status].to_i
            when TrackLog.status_spa_sha_value
              raise '该机构已经添加过融资结算详情，不能重复添加' if @funding.spas.where(organziation_id: params[:organziation_id]).present?
              @funding.change_spas(current_user.id, {spas: [params.slice(:pay_date, :is_fee, :fee_discount, :fee_rate, :amount, :ratio, :currency, :file_spa).merge(action: 'update', id: tracklog.id)]})
            when TrackLog.status_issue_ts_value
              tracklog.change_ts(current_user.id, params[:file_ts][:blob_id])
            when TrackLog.status_contacted_value
              raise '项目进度状态选择错误' if params[:calendar].present?
            end
          end
          tracklog.member_ids = params[:member_ids]
          current_user.created_calendars.create!(params[:calendar].slice(:started_at, :ended_at, :address_id, :meeting_type).merge(meeting_category: Calendar.meeting_category_roadshow_value, track_log_id: tracklog.id, funding_id: tracklog.funding_id, organization_id: tracklog.organization_id)) if params[:calendar].present?
          tracklog.track_log_details.create(params.slice(:content).merge(user_id: current_user.id)) if params[:content].present?
          present tracklog, with: Entities::TrackLogBase
        end

        desc '项目进度数量', entity: Entities::TrackLogBase
        params do
        end

        get 'count' do
          track_logs = @funding.track_logs
          track_log_counts = TrackLog.status_id_name(:key).map do |ins|
            {
                id: ins[:id],
                name: ins[:name],
                count: track_logs.try("status_#{ins[:key]}").count
            }
          end
          {track_log_counts: track_log_counts}
        end

        desc '项目进度列表', entity: Entities::TrackLogBase
        params do
          optional :status, type: Integer, desc: '项目进度状态（字典：track_log_status）'
          optional :no_status, type: Integer, desc: '项目进度状态（字典：track_log_status）'
          optional :organization_id, type:  Integer, desc: '机构id'
          optional :keyword, type: String, desc: '关键字'
        end

        get do
          track_logs = @funding.track_logs.includes(:organization, :members, :track_log_details).search(params)
          present track_logs, with: Entities::TrackLogBase
        end

        desc '导出项目进度列表', entity: Entities::FundingLite
        params do
          optional :keyword, type: String, desc: '关键字'
        end

        get 'export' do
          file_path, file_name = @funding.export_track_log(params)
          header['Content-Disposition'] = "attachment; filename=\"#{File.basename(file_name)}.xls\""
          content_type("application/octet-stream")
          env['api.format'] = :binary
          body File.read file_path
        end
      end
    end
  end

  resource :track_logs do
    resource ':id' do
      before do
        @track_log = TrackLog.find params[:id]
      end

      desc '阶段变更', entity: Entities::TrackLogDetail
      params do
        optional :file_ts, type: Hash do
          optional :blob_id, type: Integer, desc: 'ts文件id'
        end

        optional :pay_date, type: String, desc: '结算日期', regexp: /^\d{4}-\d{2}$/
        optional :is_fee, type: Boolean, desc: '是否收费'
        optional :fee_rate, type: Float, desc: '费率'
        optional :fee_discount, type: Float, desc: '费率折扣'
        optional :amount, type: Float, desc: '投资金额'
        optional :currency, type: Integer, desc: '币种'
        optional :ratio, type: Float, desc: '股份比例'
        optional :file_spa, type: Hash do
          optional :blob_id, type: Integer, desc: 'spa文件id'
        end

        optional :calendar, type: Hash do
          requires :started_at, type: Time, desc: '开始时间'
          requires :ended_at, type: Time, desc: '结束时间'
          optional :address_id, type: Integer, desc: '会议地点id'
          requires :meeting_type, type: Integer, desc: '约见类型'
        end

        requires :status, type: Integer, desc: '状态（字典：track_log_status）'
        optional :content, type: String, desc: 'Drop或Pass原因'
      end

      post 'status_change' do
        params[:user_id] = current_user.id
        @track_log.change_status_and_gen_detail(params)
        track_log_details = @track_log.track_log_details
        present track_log_details, with: Entities::TrackLogDetail
      end

      desc '跟进记录', entity: Entities::TrackLogDetail
      params do
      end

      get 'track_log_details' do
        track_log_details = @track_log.track_log_details
        present track_log_details, with: Entities::TrackLogDetail
      end

      desc '会议', entity: Entities::Calendar
      get :calendars do
        present @track_log.calendars, with: Entities::CalendarForShow
      end
    end
  end
end
