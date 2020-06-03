class DictVersion < ApplicationRecord

  DICT_CLASS_ARR = ['DefaultTeam']

  def self.update_dict(extra_hash)
    if (dict_version = extra_hash['dict_version']) && (instance.dict_version.to_i < dict_version.to_i)
      DICT_CLASS_ARR.each do |klass|
        key_name = klass.underscore.pluralize
        klass.constantize.destroy_all
        extra_hash['dict_data'][key_name].each do |ins|
          klass.constantize.create ins.to_h
        end if extra_hash['dict_data'].present?
      end
      instance.update :dict_version => dict_version
    end
  end

  def self.update_user(extra_hash)
    if (user_version = extra_hash['user_version']) && (instance.user_version.to_i < user_version.to_i)
      user_rel = User.respond_to?(:with_deleted) ? User.with_deleted : User
      sso_column = User.respond_to?(:sso_column) ? User.sso_column : :sso_id
      sso_ids = User.pluck(sso_column).compact rescue []
      extra_hash['user_data'].each do |user_hash|
        user_rel.find_or_create_user user_hash
        sso_ids.delete user_hash['id'] rescue nil
      end
      User.where(sso_column => sso_ids).destroy_all if sso_ids.present?
      instance.update :user_version => user_version
    end
  end

  def self.instance
    DictVersion.first || DictVersion.create
  end

  def self.clear
    DictVersion.delete_all
  end

  def self.get_new
    client = OAuth2::Client.new(SsoClient.client_id, SsoClient.client_secret, :site => SsoClient.sso_host)
    version = instance
    hash = client.client_credentials.get_token.get("/api/get_new?dict_version=#{version.dict_version}&user_version=#{version.user_version}").parsed
    update_dict(hash)
    update_user(hash)
  end

  def self.get_sso_user(sso_id)
    get_sso_users_index_by_id[sso_id]
  end

  def self.get_sso_users_index_by_id
    Rails.cache.fetch('sso_user_cache_index_of_id', ({expires_in: SsoClient.cache_timeout} if SsoClient.cache_timeout)) do
      get_sso_users.index_by &:id
    end
  end

  def self.get_sso_users
    Rails.cache.fetch('sso_user_cache', ({expires_in: SsoClient.cache_timeout} if SsoClient.cache_timeout)) do
      hash = SsoClient.client.client_credentials.get_token.get("/api/get_users").parsed
      hash['user_data'].map do |user|

        user = user.merge(:team_name => (hash['team_data'].find {|team| team['id'] == user['team_id']})['name']) rescue user
        user = user.merge(:name_with_team => "#{user['name']}#{"(#{user[:team_name]})" if user[:team_name]}") rescue user
        user = user.merge(:sso_id => user['id']) rescue user
        Hashie::Mash.new(user)
      end
    end
  end
end