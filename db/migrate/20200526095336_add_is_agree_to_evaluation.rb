class AddIsAgreeToEvaluation < ActiveRecord::Migration[6.0]
  def change
    add_column :evaluations, :is_agree, :string
  end
end
