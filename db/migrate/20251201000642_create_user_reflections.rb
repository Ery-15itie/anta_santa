class CreateUserReflections < ActiveRecord::Migration[7.2]
  def change
    create_table :user_reflections do |t|
      t.references :user, null: false, foreign_key: true
      t.references :reflection_question, null: false, foreign_key: true
      t.text :answer

      t.timestamps
    end
  end
end
