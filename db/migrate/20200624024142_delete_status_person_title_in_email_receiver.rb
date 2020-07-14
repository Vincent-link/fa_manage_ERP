class DeleteStatusPersonTitleInEmailReceiver < ActiveRecord::Migration[6.0]
  def change
    remove_column :email_receivers, :status, :integer, comment: '状态'
    remove_column :email_receivers, :person_title, :string, comment: '称谓'
  end
end
