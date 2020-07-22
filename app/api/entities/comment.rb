module Entities
  class Comment < Base
    expose :id
    expose :commentable_id
    expose :type
    expose :content

    expose :user, using: Entities::User
    expose :relate_user_ids do |ins|
      CacheBox.user_cache.slice(*ins.relate_user_ids)
    end

    with_options(format_with: :time_to_s_minute) do
      expose :created_at
      expose :updated_at
    end
  end
end