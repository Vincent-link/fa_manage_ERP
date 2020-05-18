class Grade < DefaultGrade
  has_many :users, foreign_key: :grade_id

end
