class RmIsAgreeFromEvaluation < ActiveRecord::Migration[6.0]
  def change
    remove_column :evaluations, :is_agree
  end
end
