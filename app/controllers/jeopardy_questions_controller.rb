class JeopardyQuestionsController < ApplicationController
  def show
    @question = JeopardyQuestion.find(params[:id])
    @game = JeopardyGame.find(params[:game_id])
  end

  def update

  end
end
