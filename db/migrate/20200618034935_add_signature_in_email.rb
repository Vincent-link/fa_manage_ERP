class AddSignatureInEmail < ActiveRecord::Migration[6.0]
  def change
    add_column :emails, :signature_template, :integer, comment: '签名模板id'
    add_column :emails, :signature, :string, comment: '签名'
  end
end
