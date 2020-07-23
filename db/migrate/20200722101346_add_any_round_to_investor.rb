class AddAnyRoundToInvestor < ActiveRecord::Migration[6.0]
  def change
    add_column :members, :any_round, :boolean
  end
end
