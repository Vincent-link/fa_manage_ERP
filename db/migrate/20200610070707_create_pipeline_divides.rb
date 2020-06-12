class CreatePipelineDivides < ActiveRecord::Migration[6.0]
  def change
    create_table :pipeline_divides do |t|
      t.integer :pipeline_id
      t.integer :user_id, comment: '分成人id'
      t.integer :bu_id, comment: '分成buid'
      t.integer :team_id, comment: '分成团队id'
      t.integer :rate, comment: '分成比例'

      t.timestamps
    end
  end
end
