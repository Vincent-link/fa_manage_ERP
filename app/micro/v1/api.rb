module V1
  class Api < Grape::API
    format :json
    mount FundingApi
    mount UserApi
  end
end
