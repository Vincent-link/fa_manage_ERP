class AddTeamsToOrganization < ActiveRecord::Migration[6.0]
  def change
    add_column :organizations, :teams, :string, array: true
  end
end
