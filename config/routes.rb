Rails.application.routes.draw do
  sso_routes
  root 'stub#index'
  mount ApiBase => '/api'
end
