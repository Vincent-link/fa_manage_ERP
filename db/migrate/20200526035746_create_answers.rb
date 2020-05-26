class CreateAnswers < ActiveRecord::Migration[6.0]
  def change
    create_table :answers do |t|
      t.text :desc
      t.belongs_to :user, index: true
      t.belongs_to :question, index: true
      t.timestamps
    end
  end
end
