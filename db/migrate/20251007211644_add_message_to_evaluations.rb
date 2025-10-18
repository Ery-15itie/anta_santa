class AddMessageToEvaluations < ActiveRecord::Migration[7.2]
  def change
    add_column :evaluations, :message, :text
    add_column :evaluations, :from_name, :string
  end
end
