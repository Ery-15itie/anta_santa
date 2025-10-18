class CreateTemplateItems < ActiveRecord::Migration[7.2]
  def change
    create_table :template_items do |t|
      t.references :template, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.string :item_type
      t.integer :weight

      t.timestamps
    end
  end
end
