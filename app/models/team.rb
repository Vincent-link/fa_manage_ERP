class Team < DefaultTeam
  has_many :users
  has_many :kpi_groups
end
