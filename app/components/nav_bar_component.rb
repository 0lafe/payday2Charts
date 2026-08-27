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
    (params[:controller] == 'draft_games') && (["show", "stream_header", "stream_footer"].include?(params[:action]))
  end
end