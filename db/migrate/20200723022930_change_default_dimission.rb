class ChangeDefaultDimission < ActiveRecord::Migration[6.0]
  def change
    change_column_default :members, :is_dimission, false
  end
end
