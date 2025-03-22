class JeopardyGamesController < ApplicationController
  def index

  end

  def show
    @game = JeopardyGame.find(params[:id])
  end

  def create
    @game = JeopardyGame.create(jeopardy_game_params)
    respond_to do |format|
      format.turbo_stream do
        redirect_to jeopardy_game_path(@game)
      end
    end
  end

  def new
    @jeopardy_game = JeopardyGame.new

    if params[:double_jeopardy] == "true"
      6.times do
        category = @jeopardy_game.jeopardy_categories.build
        5.times { |i| category.jeopardy_questions.build(value: 400 * (i + 1)) }
      end
    else
      6.times do
        category = @jeopardy_game.jeopardy_categories.build
        5.times { |i| category.jeopardy_questions.build(value: 200 * (i + 1)) }
      end
    end

  end

  def update
    @game = JeopardyGame.find(params[:id])
    @game.update(jeopardy_game_params)
  end

  def reset
    @game = JeopardyGame.find(params[:id])
    @game.jeopardy_questions.update_all(answered: false)
    @game.jeopardy_players.destroy_all
  end

  def answer_question
    @game = JeopardyGame.find(params[:id])
    @question = JeopardyQuestion.find(params[:question_id])
    @player = JeopardyPlayer.find(params['jeopardy_game']['player']['player'])

    @question.update(answered: true)
    if params[:commit] == 'right'
      if @question.variable_points?
        @player.score += params[:jeopardy_game][:variable_points][:variable_points].to_i
      else
        @player.score += @question.value
      end
    else
      @player.score -= @question.value
    end
    @player.save
  end

  private

  def jeopardy_game_params
    params.require(:jeopardy_game).permit(
      :name,
      jeopardy_players_attributes: [
        :id,
        :name,
        :_delete
      ],
      jeopardy_categories_attributes: [
        :id,
        :title,
        jeopardy_questions_attributes: [
          :id,
          :question,
          :answer,
          :value,
          :image,
          :variable_points
        ]
      ]
    )
  end
end
