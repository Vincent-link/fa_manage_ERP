Rails.application.routes.draw do
  sso_routes
  root 'stub#index'
  mount ApiBase => '/api'
  mount V1::Api => '/micro/v1'
end
