class JeopardyGamesController < ApplicationController
  before_action :set_jeopardy_game, only: %i[show update reset answer_question next_game]

  def index; end

  def show; end

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
    @game.update(jeopardy_game_params)
  end

  def reset
    @game.jeopardy_questions.update_all(answered: false)
    @game.jeopardy_players.destroy_all
  end

  def answer_question
    @question = JeopardyQuestion.find(params[:question_id])
    @correct = params[:commit] == "Right" || params[:commit] == "Complete"
    if params['jeopardy_game']['player']['player'].present?
      @player = JeopardyPlayer.find(params['jeopardy_game']['player']['player'])
    end

    if @correct
      @question.update(answered: true)
      if @player
        if @question.variable_points?
          @player.score += params[:jeopardy_game][:variable_points][:variable_points].to_i
        else
          @player.score += @question.value
        end
      end
    else
      @player.score -= @question.value
    end

    @player.save if @player
  end

  def next_game
    @next_game = @game.next_game

    @game.move_players_to_next_game

    redirect_to jeopardy_game_path(@next_game)
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

  def set_jeopardy_game
    @game = JeopardyGame.find(params[:id])
  end
end
