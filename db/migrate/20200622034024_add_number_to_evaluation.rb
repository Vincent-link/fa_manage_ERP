class AddNumberToEvaluation < ActiveRecord::Migration[6.0]
  def change
    add_column :evaluations, :number, :integer, comment: "投票序号"
  end
end
