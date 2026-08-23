class DraftGame < ApplicationRecord
  has_many :draft_game_users
  has_many :users, through: :draft_game_users
  has_many :draft_bans
  has_many :draft_choices

  belongs_to :user

  after_create :generate_public_key

  after_touch :association_updated

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

  def current_turn_user
    case stage
    when "heist_bans"
      ban_count = draft_bans.heist.count

      team = if ban_count == 0 || ban_count == 3
        "team_a"
      else
        "team_b"
      end

      # team_captain(team)
      team_captain("team_a")
    end
  end

  def update_interaction_area
    DraftGameChannel.broadcast_to(
      self,
      self.client_state
    )
  end

  def available_heists
    (base_heists - draft_bans.heist.map(&:name))
      .map do |heist_path|
        [
          heist_path,
          heist_path.gsub('.png', '').titleize
        ]
      end
  end

  def client_state
    {
      stage:,
      current_turn_user_id: current_turn_user&.id,
      host_user_id: user.id,
      team_a_user_ids: draft_game_users.team_a.pluck(:user_id),
      team_b_user_ids: draft_game_users.team_b.pluck(:user_id),
      available_heists:
    }
  end

  def set_stage
    case stage
    when "waiting"
      if draft_game_users.count >= 1
        update_column("stage", "heist_bans")
      end
    when "heist_bans"
      if draft_bans.heist.count >= heist_ban_count
        update_column("stage", "perk_bans")
      end
    end
  end

  def association_updated
    set_stage

    update_interaction_area
  end
end