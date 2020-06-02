class ChangeSourceInFunding < ActiveRecord::Migration[6.0]
  def change
    rename_column :fundings, :sources_type, :source_type
    rename_column :fundings, :sources_member, :source_member
    rename_column :fundings, :sources_detail, :source_detail
  end
end
