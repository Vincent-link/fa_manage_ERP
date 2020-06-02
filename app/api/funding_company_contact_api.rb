class FundingCompanyContactApi < Grape::API
  helpers ::Helpers::FundingBigHelpers

  resource :fundings do
    resource ':id' do
      before do
        @funding = Funding.find params[:id]
      end

      resource :funding_company_contacts do
        desc '新增团队成员', entity: Entities::FundingCompanyContact
        params do
          requires :name, type: String, desc: '成员名称'
          optional :position_id, type: Integer, desc: '职位（字典funding_contact_position）'
          optional :email, type: String, desc: '邮箱'
          optional :mobile, type: String, desc: '手机号码'
          optional :wechat, type: String, desc: '微信号'
          optional :is_attend, type: Boolean, desc: '是否参会'
          # optional :is_open, type: Boolean, desc: '是否公开名片'
          optional :description, type: String, desc: '简介'
        end
        post do
          funding_company_contact = @funding.gen_funding_company_contact(params)
          present funding_company_contact, with: Entities::FundingCompanyContact
        end
      end
    end
  end

  resource :funding_company_contacts do
    resource ':id' do
      before do
        @funding_company_contact = FundingCompanyContact.find params[:id]
      end

      desc '编辑团队成员', entity: Entities::FundingCompanyContact
      params do
        optional :name, type: String, desc: '成员名称'
        optional :position_id, type: Integer, desc: '职位（字典funding_contact_position）'
        optional :email, type: String, desc: '邮箱'
        optional :mobile, type: String, desc: '手机号码'
        optional :wechat, type: String, desc: '微信号'
        optional :is_attend, type: Boolean, desc: '是否参会'
        # optional :is_open, type: Boolean, desc: '是否公开名片'
        optional :description, type: String, desc: '简介'
      end
      patch do
        @funding_company_contact.update(params.slice(:name, :position_id, :email,
                                                     :mobile, :wechat, :is_attend,
                                                     :is_open, :description))
        present @funding_company_contact, with: Entities::FundingCompanyContact
      end

      desc '删除团队成员'
      delete do
        @funding_company_contact.destroy
      end
    end
  end
end