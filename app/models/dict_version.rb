class DictVersion < ApplicationRecord
  def self.update_dict(extra_hash)
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
end