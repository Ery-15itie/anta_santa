class AddFieldsToTemplateItems < ActiveRecord::Migration[7.2]
  def change
    add_column :template_items, :category, :string
    add_column :template_items, :sub_category, :string
  end
end
