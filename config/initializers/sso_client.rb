SsoClient.configure do |config|
  # ----------------------
  #   Oauth2 infomations
  # ----------------------
  # For more information, contact your Oauth2 provider.
  #

  config.app_name = Settings.sso_client.app_name
  config.sso_host = Settings.sso_client.sso_host
  config.client_id = Settings.sso_client.client_id
  config.client_secret = Settings.sso_client.client_secret
end

ActiveSupport.on_load :action_controller_api do
  include SsoClient::Helpers
end