class AddEvaluationIdToQuestion < ActiveRecord::Migration[6.0]
  def change
    add_reference :questions, :evaluation, index: true
  end
end
