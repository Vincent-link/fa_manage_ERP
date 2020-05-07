class ChangeOrgColumns < ActiveRecord::Migration[6.0]
  def change
    remove_column :organizations, :cache_tag
    remove_column :organizations, :cache_round
    remove_column :organizations, :cache_sector
    remove_column :organizations, :cache_currency

    add_column :organizations, :cache_tag_ids, :integer, array: true, comment: '缓存标签id'
    add_column :organizations, :cache_round_ids, :integer, array: true, comment: '缓存轮次id'
    add_column :organizations, :cache_sector_ids, :integer, array: true, comment: '缓存行业id'
    add_column :organizations, :cache_currency_ids, :integer, array: true, comment: '缓存币种id'
    add_column :organizations, :cache_invest_stage_ids, :integer, array: true, comment: '缓存阶段id'
  end
end
