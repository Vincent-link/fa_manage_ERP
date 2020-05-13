class CreateMemberResumes < ActiveRecord::Migration[6.0]
  def change
    create_table :member_resumes do |t|
      t.integer :organization_id
      t.integer :member_id
      t.string :title
      t.date :started_date
      t.date :closed_date
      t.integer :user_id

      t.timestamps
    end
  end
end
