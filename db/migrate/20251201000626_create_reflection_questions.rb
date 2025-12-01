class CreateReflectionQuestions < ActiveRecord::Migration[7.2]
  def change
    create_table :reflection_questions do |t|
      t.text :body
      t.string :category
      t.integer :position

      t.timestamps
    end
  end
end
