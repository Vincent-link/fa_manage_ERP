module V1
  class FundingApi < Grape::API
    format :json

    include ZombieService
    source_model :Funding
    model_attrs :_all_attrs

    chain_methods :my_fundings, :where, :includes

    model_methods_in_get :users

    model_class_methods_in_get :all_funding_ids
  end
end