class NavBarComponent < ViewComponent::Base
  include ApplicationHelper

  def initialize; end

  def render?
    !jeopardy? && !draft_game?
  end

  def jeopardy?
    (params[:controller] == 'jeopardy_games') && (params[:action] != 'index')
  end

  def draft_game?
    (params[:controller] == 'draft_games') && (params[:action] == 'show')
  end
end