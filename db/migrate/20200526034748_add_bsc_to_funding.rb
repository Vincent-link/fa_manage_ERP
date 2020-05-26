class AddBscToFunding < ActiveRecord::Migration[6.0]
  def change
    add_column :fundings, :bsc_status, :string, comment: 'bsc状态'
    add_column :fundings, :investment_committee_opinion, :text, comment: '投资委员会意见'
    add_column :fundings, :project_team_opinion, :text, comment: '项目组意见'
    add_column :fundings, :conference_team_ids, :integer, array: true, comment: '上会团队成员id'
  end
end
