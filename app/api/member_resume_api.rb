class MemberResumeApi < Grape::API
  resource :members do
    resource ':member_id' do
      resource :member_resumes do

        before do
          @member = Member.find(params[:member_id])
        end

        desc '工作经历'
        get do
          present @member.member_resumes, with: Entities::MemberResume
        end

        desc '新增工作经历'
        params do
          requires :organization_id, type: Integer, desc: '就职机构id'
          optional :title, type: String, desc: '职位'
          optional :started_date, type: Date, desc: '开始时间'
          optional :closed_date, type: Date, desc: '结束时间'
        end
        post do
          resume = @member.member_resumes.create(organization_id: params[:organization_id]) do |r|
            r.attributes = declared(params)
          end
          present resume, with: Entities::MemberResume
        end
      end
    end
  end

  resource :member_resumes do
    resource ':id' do
      before do
        @member_resume = MemberResume.find(params[:id])
      end

      desc '删除工作经历'
      delete do
        @member_resume.destroy!
      end

      desc '更新工作经历'
      params do
        requires :organization_id, type: Integer, desc: '就职机构id'
        optional :title, type: String, desc: '职位'
        optional :started_date, type: Date, desc: '开始时间'
        optional :closed_date, type: Date, desc: '结束时间'
      end
      patch do
        @member_resume.update!(declared(params))
        present @member_resume, with: Entities::MemberResume
      end
    end
  end
end