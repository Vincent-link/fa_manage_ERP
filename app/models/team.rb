class Team < DefaultTeam
  has_many :users, foreign_key: :team_id

end
