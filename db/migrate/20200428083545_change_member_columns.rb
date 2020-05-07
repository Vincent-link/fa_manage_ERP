class ChangeMemberColumns < ActiveRecord::Migration[6.0]
  def change
    remove_column :members, :position
    remove_column :members, :title
    remove_column :members, :cache_sector
    remove_column :members, :cache_round
    remove_column :members, :cache_currency

    add_column :members, :position, :string, comment: '职位'
    add_column :members, :position_rank_id, :integer, comment: '对应职级'
    add_column :members, :cache_sector_ids, :integer, array: true, comment: '缓存行业id'
    add_column :members, :cache_round_ids, :integer, array: true, comment: '缓存轮次id'
    add_column :members, :cache_currency_ids, :integer, array: true, comment: '缓存币种id'
    add_column :members, :cache_invest_stage_ids, :integer, array: true, comment: '缓存阶段id'
  end
end
