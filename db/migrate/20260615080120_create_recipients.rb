class CreateRecipients < ActiveRecord::Migration[8.0]
  def change
    create_table :recipients do |t|
      t.references :campaign, null: false, foreign_key: true
      t.string :name, null: false
      t.string :email, null: false
      t.integer :status, default: 0, null: false

      t.timestamps
    end
    add_index :recipients, :status
  end
end
