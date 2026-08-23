class DraftGame < ApplicationRecord
  has_many :draft_game_users
  has_many :users, through: :draft_game_users
  has_many :draft_bans
  has_many :draft_choices

  belongs_to :user

  after_create :generate_public_key

  enum :stage, {
    waiting: 0,
    heist_bans: 1,
    perk_bans: 2,
    perk_choices: 3,
    weapon_bans: 4,
    weapon_choices: 5,
  }

  def generate_public_key
    update_column(
      'public_key',
      Sqids.new(min_length: 8).encode([self.id])
    )
  end

  def to_param
    public_key
  end

  def in_game?(user)
    users.include?(user)
  end

  def team_captain(team)
    draft_game_users
      .where(team:)
      .order(id: :asc)
      .first
      &.user
  end

  def full?
    draft_game_users.count >= 1
  end

  def current_turn_user
    case stage
    when "heist_bans"
      ban_count = draft_bans.where(draft_type: 'heist').count

      team = if ban_count == 0 || ban_count == 3
        "team_a"
      else
        "team_b"
      end

      team_captain(team)
    end
  end

  # def update_interaction_area
  #   broadcast_replace_to(
  #     self,
  #     target: "interaction-area",
  #     partial: "draft_games/interaction_area",
  #     locals: {
  #       draft_game: self,
  #       user: nil
  #     }
  #   )

  #   next_user = current_turn_user

  #   broadcast_replace_to(
  #     [self, next_user],
  #     target: "interaction-area",
  #     partial: "draft_games/interaction_area",
  #     locals: {
  #       draft_game: self,
  #       user: next_user
  #     }
  #   )
  # end

  def update_interaction_area
    DraftGameChannel.broadcast_to(
      self,
      self.client_state
    )
  end

  def available_heists
    
  end

  def client_state
    {
      stage:,
      current_turn_user_id: current_turn_user&.id,
      host_user_id: user.id,
      team_a_user_ids: draft_game_users.team_a.pluck(:user_id),
      team_b_user_ids: draft_game_users.team_b.pluck(:user_id),
    }
  end
end