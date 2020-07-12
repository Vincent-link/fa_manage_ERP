class PipelineVv2 < ActiveRecord::Migration[6.0]
  def change
    change_column :pipelines, :est_amount, :decimal, precision: 10, scale: 2
    change_column :pipelines, :fee_rate, :decimal, precision: 6, scale: 2
    change_column :pipelines, :fee_discount, :decimal, precision: 10, scale: 2
    change_column :pipelines, :other_amount, :decimal, precision: 10, scale: 2
    change_column :pipelines, :complete_rate, :decimal, precision: 6, scale: 2
    change_column :pipelines, :total_fee, :decimal, precision: 10, scale: 2
    change_column :pipelines, :currency_rate, :decimal, precision: 6, scale: 2

    add_column :pipelines, :name, :string
  end
end
