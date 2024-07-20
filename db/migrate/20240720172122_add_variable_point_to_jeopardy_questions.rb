class AddVariablePointToJeopardyQuestions < ActiveRecord::Migration[7.0]
  def change
    add_column :jeopardy_questions, :variable_points, :boolean, default: false
  end
end
