class AddCurrencyInTrackLog < ActiveRecord::Migration[6.0]
  def change
    add_column :track_logs, :currency, :integer, comment: '币种'
  end
end
