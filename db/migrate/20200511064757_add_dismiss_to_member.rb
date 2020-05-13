class AddDismissToMember < ActiveRecord::Migration[6.0]
  def change
    add_column :members, :is_dismiss, :boolean, index: true, comment: '是否离职'
  end
end
