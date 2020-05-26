class FundingApi < Grape::API
  mount BscApi, with: {owner: 'fundings'}
end
