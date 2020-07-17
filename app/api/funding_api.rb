class FundingApi < Grape::API
  helpers ::Helpers::FundingBigHelpers

  resource :fundings do
    desc '创建项目', entity: Entities::FundingLite
    params do
      requires :category, type: Integer, desc: '项目类型（字典funding_category）'
      optional :category_name, type: String, desc: '其他类型的名字'
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
      optional :team_desc, type: String, desc: '团队介绍'
      optional :other_desc, type: String, desc: '其他'
      optional :source_type, type: Integer, desc: '融资来源类型(字典funding_source_type)'
      optional :source_member, type: Integer, desc: '投资者'
      optional :source_detail, type: String, desc: '来源明细'
      optional :funding_score, type: Integer, desc: '项目评分'

      optional :file_materials, type: Hash do
        optional :blob_id, type: Array[Integer], desc: '附件blob文件id'
        optional :id, type: Array[Integer], desc: '新建里这个字段没用'
      end

      optional :normal_user_ids, type: Array[Integer], desc: '项目成员id'
      optional :bd_leader_id, type: Integer, desc: 'BD负责人id'
      optional :execution_leader_id, type: Integer, desc: '执行负责人id'

      optional :file_teaser, type: Hash do
        optional :blob_id, type: Integer, desc: 'Teaser文件blob_id'
        optional :id, type: Integer, desc: '新建里这个字段没用'
      end
      optional :file_bp, type: Hash do
        optional :blob_id, type: Integer, desc: 'BP文件blob_id'
        optional :id, type: Integer, desc: '新建里这个字段没用'
      end
      optional :file_nda, type: Hash do
        optional :blob_id, type: Integer, desc: 'NDA文件blob_id'
        optional :id, type: Integer, desc: '新建里这个字段没用'
      end
      optional :file_model, type: Hash do
        optional :blob_id, type: Integer, desc: 'Model文件blob_id'
        optional :id, type: Integer, desc: '新建里这个字段没用'
      end
      optional :file_el, type: Hash do
        optional :blob_id, type: Integer, desc: 'EL文件blob_id'
        optional :id, type: Integer, desc: '新建里这个字段没用'
      end

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
        requires :started_at, type: Time, desc: '开始时间'
        requires :ended_at, type: Time, desc: '结束时间'
        optional :address_id, type: Integer, desc: '会议地点id'
      end
    end
    post do
      auth_funding_code(params)
      params[:is_ka] = Company.find(params[:company_id]).is_ka
      Funding.transaction do
        @funding = Funding.create(params.slice(:category, :company_id, :round_id, :target_amount_currency, :target_amount,
                                               :share, :shiny_word, :com_desc, :products_and_business, :financial, :is_ka,
                                               :operational, :market_competition, :financing_plan, :team_desc, :other_desc,
                                               :source_type, :source_member, :source_detail, :funding_score, :name, :category_name)
                                      .merge(operating_day: Date.today))
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
      optional :type_range, type: Array[Integer], desc: "范围#{Funding.type_range_id_name}", values: Funding.type_range_values
      optional :status, type: Integer, desc: '项目状态', values: Funding.status_values
      optional :is_me, type: Boolean, desc: '是否查询我的项目'
      optional :page, type: Integer, desc: '页码', default: 1
      optional :per_page, type: Integer, desc: '数量', default: 10
    end
    get do
      params[:keyword] = '*' if ['', nil].include? params[:keyword]
      fundings = FundingPolymer.es_search(params)
      present fundings, with: Entities::FundingBaseInfo
    end

    desc '项目简略列表', entity: Entities::FundingGroupWithStatus
    params do
      optional :keyword, type: String, desc: '关键字'
      optional :status, type: Integer, desc: '项目状态', values: Funding.status_values
      optional :layout, type: String, desc: '按状态分数组: status_group'
      optional :is_me, type: Boolean, desc: '是否查询我的项目'
    end
    get 'lite' do
      params[:keyword] = '*' if ['', nil].include? params[:keyword]
      fundings = FundingPolymer.es_search(params)
      case params[:layout]
      when 'status_group'
        # 不要pass 和 hold的
        funding_results = []
        fundings.group_by{|ins| ins.status}.each{|k,v| funding_results << {status: k, data: v} unless Funding.status_filter(:pass, :hold).include?(k)}
        present funding_results, with: Entities::FundingGroupWithStatus
      else
        present fundings, with: Entities::FundingBaseInfo
      end
    end

    desc '项目列表导出'
    params do
      optional :keyword, type: String, desc: '关键字'
      optional :location_ids, type: Array[Integer], desc: '地点（字典locations）'
      optional :sector_ids, type: Array[Integer], desc: '行业（字典sector_tree）'
      optional :round_ids, type: Array[Integer], desc: '轮次(字典rounds)'
      optional :pipeline_status, type: Array[Integer], desc: 'Pipeline阶段'
      optional :type_range, type: Array[Integer], desc: "范围#{Funding.type_range_id_name}", values: Funding.type_range_values
      optional :is_me, type: Boolean, desc: '是否查询我的项目'
    end
    get do
      params[:keyword] = '*' if ['', nil].include? params[:keyword]
      file_path, file_name = FundingPolymer.export(params)
      header['Content-Disposition'] = "attachment; filename=\"#{File.basename(file_name)}.xls\""
      content_type("application/octet-stream")
      env['api.format'] = :binary
      body File.read file_path
    end

    desc '项目状态排序', entity: Entities::UserFundingStatusSort
    params do
      requires 'funding_status_sort', type: Array[Integer], desc: "项目状态排序数组"
    end
    post :status_sort do
      raise '排序数量或状态选择不对' if (params[:funding_status_sort].uniq - Funding.status_values).present? || (Funding.status_values - params[:funding_status_sort].uniq).present?
      current_user.update!(funding_status_sort: params[:funding_status_sort])
      present current_user, with: Entities::UserFundingStatusSort
    end

    desc '获取项目状态排序', entity: Entities::UserFundingStatusSort
    params do
    end
    get :status_sort do
      present current_user, with: Entities::UserFundingStatusSort
    end

    resource ':id' do
      before do
        @funding = Funding.find params[:id]
      end

      desc '编辑项目', entity: Entities::FundingLite
      params do
        optional :category, type: Integer, desc: '项目类型（字典funding_category）'
        optional :category_name, type: String, desc: '其他类型的名字'
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
        optional :team_desc, type: String, desc: '团队介绍'
        optional :other_desc, type: String, desc: '其他'
        optional :source_type, type: Integer, desc: '融资来源类型（字典funding_source_type）'
        optional :source_member, type: Integer, desc: '投资者'
        optional :source_detail, type: String, desc: '来源明细'
        optional :funding_score, type: Integer, desc: '项目评分'

        optional :file_materials, type: Hash do
          optional :blob_id, type: Array[Integer], desc: '附件blob文件id'
          optional :id, type: Array[Integer], desc: '保留的附件id'
        end

        optional :normal_user_ids, type: Array[Integer], desc: '项目成员id'
        optional :bd_leader_id, type: Integer, desc: 'BD负责人id'
        optional :execution_leader_id, type: Integer, desc: '执行负责人id'

        optional :confidentiality_level, type: Integer, desc: '保密等级'
        optional :confidentiality_reason, type: String, desc: '保密原因'
        optional :is_reportable, type: Boolean, desc: '是否出现周日报'
        optional :is_complicated, type: Boolean, desc: '是否复杂项目'
      end
      patch do
        auth_source_type(params)
        raise ' 其他类型的项目不能修改类型' if params[:category].present? && @funding.category == Funding.category_advisory_value && @funding.category != params[:category]
        Funding.transaction do
          @funding.update(params.slice(:category, :name, :round_id, :shiny_word, :post_investment_valuation, :post_valuation_currency,
                                       :target_amount, :target_amount_currency, :share, :source_type, :source_member, :source_detail,
                                       :is_complicated, :funding_score, :confidentiality_level, :confidentiality_reason, :is_reportable,
                                       :com_desc, :products_and_business, :financial, :operational, :market_competition, :financing_plan,
                                       :team_desc, :other_desc, :category_name))
          @funding.add_project_follower(params)
          @funding.funding_various_file(params)
        end
        present @funding, with: Entities::FundingLite
      end

      desc '认领项目', entity: Entities::FundingLite
      params do
        optional :desc, type: String, desc: '会议描述', default: '由项目进度生成'
        optional :contact_ids, type: Array[Integer], desc: '公司联系人id'
        requires :cr_user_ids, type: Array[Integer], desc: '华兴参与人id'
        requires :started_at, type: Time, desc: '开始时间'
        requires :ended_at, type: Time, desc: '结束时间'
        optional :address_id, type: Integer, desc: '会议地点id'
      end
      patch 'claim' do
        @funding.gen_claim_verification(declared(params, include_missing: false).merge(meeting_category: Calendar.meeting_category_com_meeting_value,
                                                                                       meeting_type: Calendar.meeting_type_face_value))
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
        optional :organization_id, type: Integer, desc: '机构id'
        optional :member_ids, type: Array[Integer], desc: '投资人id'
      end
      post 'files' do
        params[:type] = params[:type].to_i
        track_log = TrackLog.find(params[:track_log_id]) if params[:track_log_id].present?
        case
        when params[:type] == Funding.all_funding_file_type_spa_value
          if track_log.present?
            track_log.change_spa(current_user.id, params[:file][:blob_id])
          else
            track_log = @funding.track_logs.create(organization_id: params[:organization_id], status: TrackLog.status_spa_sha_value)
            track_log.change_spa(current_user.id, params[:file][:blob_id])
            track_log.member_ids = params[:member_ids]
          end
          file = track_log.file_spa_attachment
        when params[:type] == Funding.all_funding_file_type_ts_value
          if track_log.present?
            track_log.change_ts(current_user.id, params[:file][:blob_id])
          else
            track_log = @funding.track_logs.create(organization_id: params[:organization_id], status: TrackLog.status_issue_ts_value)
            track_log.change_ts(current_user.id, params[:file][:blob_id])
            track_log.member_ids = params[:member_ids]
          end
          file = track_log.file_ts_attachment
          track_log.update!(status: TrackLog.status_issue_ts_value) unless track_log.status_spa_sha?
        when params[:type] == Funding.all_funding_file_type_materials_value
          file = @funding.file_materials_file_add(blob_id: params[:file][:blob_id]).first
        when Funding.all_funding_file_type_filter(:bp, :el, :teaser, :nda, :model).include?(params[:type])
          file = @funding.try("#{Funding.all_funding_file_type_value_code(params[:type], :file).first}_file=", params[:file])
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
        when 'FundingPolymer'
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

      desc '获取文档列表', entity: Entities::FileResult
      params do
      end
      get 'files' do
        tr_file = ActiveStorage::Attachment.where(name: ['file_ts', 'file_spa'], record_type: "TrackLog", record_id: @funding.track_log_ids)
        f_file = ActiveStorage::Attachment.where(name: ['file_bp', 'file_teaser', 'file_model', 'file_el', 'file_nda', 'file_materials'], record_type: "FundingPolymer", record_id: @funding.id)
        organizations = @funding.track_logs.map {|ins| [ins.id, ins.organization]}.to_h
        files = (tr_file + f_file).group_by{|ins| ins.name}
        file_array = ['file_bp', 'file_teaser', 'file_model', 'file_nda', 'file_el', 'file_ts', 'file_spa', 'file_materials']
        file_hash = FundingPolymer.all_funding_file_type_config.values.map{|ins| [ins[:file], ins[:desc]]}.to_h
        file_results = file_array.map{|ins| {file_type: file_hash[ins], data: files[ins] || []}}
        present file_results, with: Entities::FileResult, organizations: organizations
      end

      desc '设置为ka', entity: Entities::FundingLite
      params do
      end
      post 'set_as_ka' do
        #todo 判断管理员权限 如果是管理员直接设置ka
        @funding.gen_ka_verification
        present @funding, with: Entities::FundingLite
      end

      desc '取消ka', entity: Entities::FundingLite
      params do
      end
      post 'cancel_ka' do
        raise '此项目不是ka项目' unless @funding.is_ka
        @funding.update!(is_ka: false)
        present @funding, with: Entities::FundingLite
      end

      desc '项目对应公司的融资历史', entity: Entities::FundingHistoryLite
      params do
      end
      get 'history_lite' do
        fundings = @funding.company.fundings
        present fundings, with: Entities::FundingHistoryLite
      end

    end
  end

  mount BscApi, with: {owner: 'fundings'}
end
