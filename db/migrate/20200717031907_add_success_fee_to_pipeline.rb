class AddSuccessFeeToPipeline < ActiveRecord::Migration[6.0]
  def change
    remove_column :pipelines, :fee_discount
    remove_column :pipelines, :other_amount_currency

    add_column :pipelines, :success_fee, :decimal, precision: 10, scale: 2
  end
end
