class KpiGroup < ApplicationRecord
  has_many :kpis, dependent: :destroy
  has_many :users

  def users_ids=(*ids)
    self.users.update!(kpi_group_id: nil)
    ids.flatten.each do |id|
      add_user_by_id id
    end
  end

  def add_user_by_id id
    User.find(id).update!(kpi_group_id: self.id)
  end
end
