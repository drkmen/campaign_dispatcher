class CreateCampaigns < ActiveRecord::Migration[8.0]
  def change
    create_table :campaigns do |t|
      t.string :title, null: false
      t.integer :status, default: 0, null: false

      t.timestamps
    end
  end
end
