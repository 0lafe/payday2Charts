class JeopardyQuestionsController < ApplicationController
  def show
    @question = JeopardyQuestion.find(params[:id])
    @game = JeopardyGame.find(params[:game_id])
  end

  def update
    @question = JeopardyQuestion.find(params[:id])
    @game = @question.jeopardy_game
    @question.update(question_params)
  end

  private

  def question_params
    params.require(:jeopardy_question).permit(:question, :answer, :image, :variable_points)
  end
end
