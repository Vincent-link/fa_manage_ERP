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
            requires :pay_date, type: Date, desc: '结算日期'
            requires :is_fee, type: Boolean, desc: '是否收费'
            requires :fee_rate, type: Float, desc: '费率'
            requires :fee_discount, type: Float, desc: '费率折扣'
            requires :amount, type: Float, desc: '投资金额'
            requires :ratio, type: Float, desc: '股份比例'
            requires :file_spa, type: Hash do
              optional :blob_id, type: Integer, desc: '重新上传的spa文件id'
              optional :id, type: Integer, desc: 'spa_id'
            end
          end
          # todo 需要pipline id
        end

        post 'spa' do
          spas = @funding.spas
          params[:spas].each do |spa|
            case spa[:action]
            when 'delete'
              spas.find(spa[:id]).destroy
            when 'update'
              spas.find(spa[:id]).update!(spa.slice(:pay_date, :is_fee, :fee_discount, :fee_rate, :amount, :ratio))
              if spa[:file_spa][:blob_id].present?

              end
            end
          end
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

          optional :spa_msg, type: Hash do
            requires :pay_date, type: Date, desc: '结算日期'
            requires :is_fee, type: Boolean, desc: '是否收费'
            requires :fee_rate, type: Float, desc: '费率'
            requires :fee_discount, type: Float, desc: '费率折扣'
            requires :amount, type: Float, desc: '投资金额'
            requires :currency, type: Integer, desc: '币种'
            requires :ratio, type: Float, desc: '股份比例'
            requires :bob_id, type: Integer, desc: 'spa文件id'
          end

          optional :calendar, type: Hash do
            requires :started_at, type: DateTime, desc: '开始时间'
            requires :ended_at, type: DateTime, desc: '结束时间'
            optional :address_id, type: Integer, desc: '会议地点id'
            requires :meeting_type, type: Integer, desc: '约见类型'
          end
        end

        post do
          raise '项目进度状态选择错误' if params[:calendar].present? && params[:track_log_id].nil? && params[:status] != TrackLog.status_meeting_value
          organziation = Organization.find(params[:organization_id])
          params[:member_ids] = organziation.members.where(:params[:member_ids]).map(&:id)
          if params[:track_log_id].present?
            tracklog = @funding.track_logs.find(params[:track_log_id])
            tracklog.update(status: TrackLog.status_meeting_value) if params[:calendar].present? && tracklog.status_contacted?
            params[:member_ids] |= tracklog.member_ids
            raise '此项目进度的机构与添加投资人的机构不是同一机构' if tracklog.organization_id != params[:organization_id]
          else
            tracklog = @funding.track_logs.create(params.slice(:status, :organization_id, :has_bp, :has_teaser, :has_nda, :has_model))
          end
          tracklog.member_ids = params[:member_ids]
          calendar = current_user.created_calendars.create!(params[:calendar].slice(:started_at, :ended_at, :address_id, :meeting_type).merge(meeting_category: Calendar.meeting_category_roadshow_value))
          tracklog.track_log_details.create(params.slice(:content).merge(user_id: current_user.id, linkable_id: calendar.id, linkable_type: calendar.class.to_s))
          present tracklog, with: Entities::TrackLogBase
        end

        desc '项目进度列表', entity: Entities::TrackLogBase
        params do
          requires :status, type: Integer, desc: '项目进度状态'
          optional :keyword, type: String, desc: '关键字'
        end

        get do
          track_logs = @funding.track_logs.includes(:organization, :members, :track_log_details).search(params)
          present track_logs, with: Entities::TrackLogBase
        end

        desc '导出项目进度列表', entity: Entities::FundingLite
        params do
          requires :status, type: Integer, desc: '项目进度状态'
          optional :keyword, type: String, desc: '关键字'
        end

        get 'export' do
          @funding.expose_track_logs
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
        requires :status, type: Integer, desc: '状态'
        optional :content, type: String, desc: 'Drop或Pass原因'
      end

      post 'status_change' do
        params[:user_id] = current_user.id
        @track_log.change_status_and_gen_detail(params)
        track_log_details = @tracklog.track_log_details
        present track_log_details, with: Entities::TrackLogDetail
      end

      desc '跟进记录', entity: Entities::TrackLogDetail
      params do
      end

      get 'track_log_details' do
        track_log_details = @tracklog.track_log_details
        present track_log_details, with: Entities::TrackLogDetail
      end
    end
  end
end
