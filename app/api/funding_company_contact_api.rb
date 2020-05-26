class FundingCompanyContactApi < Grape::API
  helpers ::Helpers::FundingBigHelpers

  resource :fundings do
    resource ':id' do
      before do
        @funding = Funding.find params[:id]
      end

      desc '新增团队成员'
      params do

      end
      post do

      end
    end
  end

  resource :funding_company_contacts do
    resource ':id' do
      before do
        @funding_company_contact = FundingCompanyContact.find params[:id]
      end

      desc '编辑团队成员'
      params do

      end
      patch do

      end

      desc '删除团队成员'
      params do

      end
      patch do

      end
    end
  end
end