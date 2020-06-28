class FundingApi < Grape::API
  helpers ::Helpers::FundingBigHelpers

  resource :fundings do
    desc '创建项目', entity: Entities::FundingLite
    params do
      requires :category, type: Integer, desc: '项目类型（字典funding_category）'
      requires :company_id, type: Integer, desc: '公司id'
      requires :name, type: String, desc: '项目名称'

      optional :round_id, type: Integer, desc: '轮次（字典rounds）'
      optional :target_amount_currency, type: Integer, desc: '交易金额币种'
      optional :target_amount, type: Float, desc: '交易金额'
      optional :share, type: Float, desc: '出让股份'
      optional :shiny_word, type: String, desc: '一句话亮点'
      optional :com_desc, type: String, desc: '公司简介'
      optional :products_and_business, type: String, desc: '产品与商业模式'
      optional :financial, type: String, desc: '财务数据'
      optional :operational, type: String, desc: '运营数据'
      optional :market_competition, type: String, desc: '市场竞争分析'
      optional :financing_plan, type: String, desc: '融资计划'
      optional :other_desc, type: String, desc: '其他'
      optional :source_type, type: Integer, desc: '融资来源类型(字典funding_source_type)'
      optional :source_member, type: Integer, desc: '投资者'
      optional :source_detail, type: String, desc: '来源明细'
      optional :funding_score, type: Integer, desc: '项目评分'

      optional :attachments, type: Array[File], desc: '附件'

      optional :normal_user_ids, type: Array[Integer], desc: '项目成员id'
      optional :bd_leader_id, type: Integer, desc: 'BD负责人id'
      optional :execution_leader_id, type: Integer, desc: '执行负责人id'

      optional :teaser, type: File, desc: 'Teaser'
      optional :bp, type: File, desc: 'BP'
      optional :nda, type: File, desc: 'NDA'
      optional :model, type: File, desc: 'Model'
      optional :el, type: File, desc: 'EL'

      # optional :funding_company_contacts, type: Array[JSON] do
      #   requires :name, type: String, desc: '成员名称'
      #   optional :position_id, type: Integer, desc: '职位（字典funding_contact_position）'
      #   optional :email, type: String, desc: '邮箱'
      #   optional :mobile, type: String, desc: '手机号码'
      #   optional :wechat, type: String, desc: '微信号'
      #   optional :description, type: String, desc: '简介'
      # end
      requires :calendar, type: Hash do
        requires :contact_ids, type: Array[Integer], desc: '公司联系人id'
        requires :cr_user_ids, type: Array[Integer], desc: '华兴参与人id'
        requires :started_at, type: DateTime, desc: '开始时间'
        requires :ended_at, type: DateTime, desc: '结束时间'
        requires :address_id, type: Integer, desc: '会议地点id'
      end
    end
    post do
      auth_funding_code(params)
      Funding.transaction do
        @funding = Funding.create(params.slice(:category, :company_id, :round_id, :target_amount_currency, :target_amount,
                                               :share, :shiny_word, :com_desc, :products_and_business, :financial,
                                               :operational, :market_competition, :financing_plan, :other_desc, :source_type,
                                               :source_member, :source_detail, :funding_score, :name).merge(operating_day: Date.today))
        @funding.add_project_follower(params)
        @funding.gen_funding_company_contacts(params)
        @funding.funding_various_file(params)
        @funding.calendars.create!(declared(params)[:calendar].merge(company_id: params[:company_id], meeting_type: Calendar.meeting_type_face_value, meeting_category: Calendar.meeting_category_com_meeting_value))
      end
      present @funding, with: Entities::FundingLite
    end

    desc '项目列表', entity: Entities::FundingBaseInfo
    params do
      optional :keyword, type: String, desc: '关键字'
      optional :location_ids, type: Array[Integer], desc: '地点（字典locations）'
      optional :sector_ids, type: Array[Integer], desc: '行业（字典sector_tree）'
      optional :round_ids, type: Array[Integer], desc: '轮次(字典rounds)'
      optional :pipeline_status, type: Array[Integer], desc: 'Pipeline阶段'
    end
    get do
      fundings = Funding.es_search(params)
      present fundings, with: Entities::FundingBaseInfo
    end

    resource ':id' do
      before do
        @funding = Funding.find params[:id]
      end

      desc '编辑项目', entity: Entities::FundingLite
      params do
        optional :category, type: Integer, desc: '项目类型（字典funding_category）'
        optional :name, type: String, desc: '项目名称'

        optional :round_id, type: Integer, desc: '轮次（字典rounds）'
        optional :post_valuation_currency, type: Integer, desc: '本轮投后估值币种'
        optional :post_investment_valuation, type: Float, desc: '本轮投后估值'
        optional :target_amount_currency, type: Integer, desc: '交易金额币种'
        optional :target_amount, type: Float, desc: '交易金额'
        optional :share, type: Float, desc: '出让股份'
        optional :shiny_word, type: String, desc: '一句话亮点'
        optional :com_desc, type: String, desc: '公司简介'
        optional :products_and_business, type: String, desc: '产品与商业模式'
        optional :financial, type: String, desc: '财务数据'
        optional :operational, type: String, desc: '运营数据'
        optional :market_competition, type: String, desc: '市场竞争分析'
        optional :financing_plan, type: String, desc: '融资计划'
        optional :other_desc, type: String, desc: '其他'
        optional :source_type, type: Integer, desc: '融资来源类型（字典funding_source_type）'
        optional :source_member, type: Integer, desc: '投资者'
        optional :source_detail, type: String, desc: '来源明细'
        optional :funding_score, type: Integer, desc: '项目评分'

        optional :attachments, type: Array[File], desc: '附件'
        optional :attachment_ids, type: Array[Integer], desc: '附件id'

        optional :normal_user_ids, type: Array[Integer], desc: '项目成员id'
        optional :bd_leader_id, type: Integer, desc: 'BD负责人id'
        optional :execution_leader_id, type: Integer, desc: '执行负责人id'

        optional :confidentiality_level, type: Integer, desc: '保密等级'
        optional :confidentiality_reason, type: String, desc: '保密原因'
        optional :is_reportable, type: Boolean, desc: '是否出现周日报'
        optional :is_complicated, type: Boolean, desc: '是否复杂项目'

        #todo 约见（5个字段的swagger）（李靖超）
      end
      patch do
        #todo 约见
        auth_source_type(params)
        raise '咨询类型的项目不能修改类型' if params[:category].present? && @funding.category == Funding.category_advisory_value && @funding.category != params[:category]
        Funding.transaction do
          @funding.update(params.slice(:category, :name, :round_id, :shiny_word, :post_investment_valuation, :post_valuation_currency,
                                       :target_amount, :target_amount_currency, :share, :source_type, :source_member, :source_detail,
                                       :is_complicated, :funding_score, :confidentiality_level, :confidentiality_reason, :is_reportable,
                                       :com_desc, :products_and_business, :financial, :operational, :market_competition, :financing_plan,
                                       :other_desc))
          @funding.add_project_follower(params)
          @funding.funding_various_file(params)
        end
        present @funding, with: Entities::FundingLite
      end

      desc '编辑项目跟进人', entity: Entities::FundingUser
      params do
        optional :normal_user_ids, type: Array[Integer], desc: '项目成员id'
        optional :bd_leader_id, type: Integer, desc: 'BD负责人id'
        optional :execution_leader_id, type: Integer, desc: '执行负责人id'
      end
      patch 'funding_user' do
        @funding.add_project_follower(params)
        present @funding, with: Entities::FundingUser
      end

      desc '项目详情', entity: Entities::FundingComprehensive
      params do
        requires :type, type: String, desc: '样式：弹窗：pop、页面：page、状态流转相关字段: status'
      end
      get do
        case params[:type]
        when 'pop'
          present @funding, with: Entities::Funding
        when 'page'
          present @funding, with: Entities::FundingComprehensive
        when 'status'
          present @funding, with: Entities::FundingStatusTransition
        end
      end

      desc '状态变更历史', entity: Entities::TimeLine
      params do
      end
      get 'timelines' do
        time_lines = @funding.time_lines
        present time_lines, with: Entities::TimeLine
      end

      desc '项目跟进人', entity: Entities::FundingUser
      params do
      end
      get 'funding_user' do
        present @funding, with: Entities::FundingUser
      end

      desc '上传文档', entity: Entities::Attachment
      params do
        requires :type, type: Integer, desc: "文件类型: #{Funding.all_funding_file_type_hash.invert}", values: Funding.all_funding_file_type_values
        requires :file, type: Hash do
          requires :blob_id, type: Integer, desc: '文件blob_id'
        end
        optional :track_log_id, type: Integer, desc: 'TrackLog id'
      end
      post 'files' do
        params[:type] = params[:type].to_i
        case
        when params[:type] == Funding.all_funding_file_type_spa_value
          track_log = TrackLog.find(params[:track_log_id])
          track_log.change_spa(current_user.id, params[:file][:blob_id])
          file = track_log.file_spa_attachment
        when params[:type] == Funding.all_funding_file_type_ts_value
          track_log = TrackLog.find(params[:track_log_id])
          track_log.change_ts(current_user.id, params[:file][:blob_id])
          file = track_log.file_ts_attachment
        when params[:type] == Funding.all_funding_file_type_materials_value
          file = ActiveStorage::Attachment.create!(name: 'file_materials', record_type: 'Funding', record_id: @funding.id, blob_id: params[:file][:blob_id])
        when Funding.all_funding_file_type_filter(:bp, :el, :teaser, :nda, :model).include?(params[:type])
          if @funding.try(Funding.all_funding_file_type_value_code(params[:type], :file).first).present?
            file = @funding.try("#{Funding.all_funding_file_type_value_code(params[:type], :file).first}_attachment")
            file.update!(blob_id: params[:file][:blob_id])
          else
            file = ActiveStorage::Attachment.create!(name: Funding.all_funding_file_type_value_code(params[:type], :file).first, record_type: 'Funding', record_id: @funding.id, blob_id: params[:file][:blob_id])
          end
        end
        present file, with: Entities::Attachment
      end

      desc '删除文档'
      params do
        requires :file_id, type: Integer, desc: '文件id'
      end
      delete 'files' do
        file = ActiveStorage::Attachment.find(params[:file_id])
        case file.record_type
        when 'Funding'
          file.delete
        when 'TrackLog'
          case file.name
          when 'file_spa'
            raise '不能在文件管理页面删除spa'
          when 'file_ts'
            file.record_type.constantize.find(file.record_id).update!(status: TrackLog.status_pass_value)
            file.delete
          end
        end
      end

      desc '获取文档列表', entity: Entities::FundingAttachment
      params do
      end
      get 'files' do
        files = {
            file_bp: @funding.file_bp_attachment,
            file_teaser: @funding.file_teaser_attachment,
            file_model: @funding.file_model_attachment,
            file_el: @funding.file_el_attachment,
            file_nda: @funding.file_nda_attachment,
            file_materials: @funding.file_materials_attachments,
            file_ts: ActiveStorage::Attachment.where(name: 'file_ts', record_type: "TrackLog", record_id: @funding.track_log_ids),
            file_spa: ActiveStorage::Attachment.where(name: 'file_spa', record_type: "TrackLog", record_id: @funding.track_log_ids)
        }
        organizations = @funding.track_logs.map {|ins| [ins.id, ins.organization]}.to_h
        present files, with: Entities::FundingAttachment, organizations: organizations
      end
    end
  end

  mount BscApi, with: {owner: 'fundings'}
end
