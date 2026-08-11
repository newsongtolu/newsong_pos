class CreatePaymentTransactions < ActiveRecord::Migration[8.1]
  def change
    create_table :payment_transactions do |t|
      t.references :order, null: false, foreign_key: true
      t.string :reference
      t.decimal :amount
      t.string :gateway
      t.string :status
      t.text :metadata

      t.timestamps
    end
  end
end
