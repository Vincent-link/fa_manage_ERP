module Entities
  class Comment < Base
    expose :id
    expose :commentable_id
    expose :type
    expose :content

    expose :user, using: Entities::User

    with_options(format_with: :time_to_s_minute) do
      expose :created_at
      expose :updated_at
    end
  end
end