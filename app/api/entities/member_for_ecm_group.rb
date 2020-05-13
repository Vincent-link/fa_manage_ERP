module Entities
  class MemberForEcmGroup < MemberForIndex
    expose :users, as: :covered_by, using: Entities::UserLite, documentation: {type: Entities::UserLite, desc: '部门对接人', is_array: true}
  end
end