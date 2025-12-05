class CreateOgpImages < ActiveRecord::Migration[7.2]
  def change
    create_table :ogp_images do |t|
      t.string :uuid

      t.timestamps
    end
    add_index :ogp_images, :uuid
  end
end
