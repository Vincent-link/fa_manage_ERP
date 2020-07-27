module Entities
  class News < Base
    expose :id, documentation: {type: 'integer', desc: '新闻id'}
    expose :title, documentation: {type: 'integer', desc: '标题'}
    expose :url, documentation: {type: 'integer', desc: 'url'}
    expose :source, documentation: {type: 'integer', desc: '来源'}

    with_options(format_with: :time_to_s_second) do
      expose :created_at, documentation: {type: 'time', desc: '创建时间'}
      expose :updated_at, documentation: {type: 'time', desc: '更新时间'}
    end
  end
end
