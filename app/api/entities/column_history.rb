module Entities
  class ColumnHistory < Base
    expose :id
    expose :whodunnit, as: :user_name
    expose :value do |version, opt|
      version.changeset[opt[:column]].last
    end

    with_options(format_with: :time_to_s_second) do
      expose :created_at
    end
  end
end