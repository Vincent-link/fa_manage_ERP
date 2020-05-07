class ChangeCacheColumns < ActiveRecord::Migration[6.0]
  def change
    rename_column :members, :cache_sector_ids, :sector_ids
    rename_column :members, :cache_currency_ids, :currency_ids
    rename_column :members, :cache_invest_stage_ids, :invest_stage_ids
    rename_column :members, :cache_round_ids, :round_ids

    rename_column :organizations, :cache_round_ids, :round_ids
    rename_column :organizations, :cache_tag_ids, :tag_ids
    rename_column :organizations, :cache_sector_ids, :sector_ids
    rename_column :organizations, :cache_currency_ids, :currency_ids
    rename_column :organizations, :cache_invest_stage_ids, :invest_stage_ids
  end
end
