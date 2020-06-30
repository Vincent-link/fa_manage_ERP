module Entities
  class Address < Base
    expose :id, documentation: {type: 'integer', desc: '地址id'}
    expose :owner_id, documentation: {type: 'integer', desc: '创建人'}
    expose :location_id, documentation: {type: 'integer', desc: '地域id'}
    expose :province_id, documentation: {type: 'integer', desc: '地域id'} do |ins|
      CacheBox.dm_locations[ins.location_id]&.parent_id
    end
    expose :address_desc, documentation: {type: 'string', desc: '地址id'}

    with_options(format_with: :dm_time_to_s_second) do
      expose :created_at, documentation: {type: 'time', desc: '创建时间'}
      expose :updated_at, documentation: {type: 'time', desc: '更新时间'}
    end
  end
end