class AddPositionToTemplateItems < ActiveRecord::Migration[7.2]
  def change
    add_column :template_items, :position, :integer, default: 0, null: false
  end
end
