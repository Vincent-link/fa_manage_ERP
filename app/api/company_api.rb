class CompanyApi < Grape::API
  resource :companies do
    resource ':id' do
    end

    mount AddressApi
  end
end