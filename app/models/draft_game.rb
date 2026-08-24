class DraftGame < ApplicationRecord
  has_many :draft_game_users
  has_many :users, through: :draft_game_users
  has_many :draft_picks

  belongs_to :user

  after_create :generate_public_key

  after_touch :association_updated

  enum :stage, {
    waiting: 0,
    heist_bans: 1,
    heist_select: 2,
    perk_bans: 3,
    perk_choices: 4,
    weapon_bans: 5,
    weapon_choices: 6,
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
      ban_count = draft_picks.ban.heist.count

      team = if ban_count == 0 || ban_count == 3
        "team_a"
      else
        "team_b"
      end

      team_captain(team)
    when "perk_bans"
      ban_count = draft_picks.ban.perkdeck.count

      team = if ban_count == 0 || ban_count == 3
        "team_a"
      else
        "team_b"
      end

      team_captain(team)
    end
  end

  def update_interaction_area
    DraftGameChannel.broadcast_to(
      self,
      self.client_state
    )
  end

  def available_heists
    (base_heists - draft_picks.ban.heist.map(&:name))
      .map do |heist_path|
        [
          heist_path,
          heist_path.gsub('.png', '').titleize
        ]
      end
  end

  def available_perkdecks
    (base_perkdecks - draft_picks.ban.perkdeck.map(&:name))
      .map do |perkdeck|
        [
          perkdeck,
          perkdeck.gsub('.png', '').titleize
        ]
      end
  end

  def available_weapons
    (base_weapons - draft_picks.ban.weapon.map(&:name))
      .map do |weapon|
        [
          weapon,
          weapon.gsub('.png', '').titleize
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
      available_heists:,
      available_perkdecks:,
      available_weapons:
    }
  end

  def set_heist
    update(heist: available_heists.sample[0])

    self.broadcast_replace_to(
      self,
      target: 'showoff-content',
      partial: "draft_games/showoff/heist",
      locals: {
        heist:,
      }
    )
  end

  def set_stage
    case stage
    when "waiting"
      if draft_game_users.count >= 2
        update_column("stage", "heist_bans")
      end
    when "heist_bans"
      if draft_picks.ban.heist.count >= heist_ban_count
        update_column("stage", "heist_select")

        AdvanceDraftGameHeistSelectJob
          .set(wait: 5.second)
          .perform_later(id)
      end
    when "perk_bans"
      if draft_picks.ban.perkdeck.count >= perkdeck_ban_count
        update_column("stage", "perk_choices")
      end
    end
  end

  def association_updated
    set_stage

    update_interaction_area
  end

  def self.reset_all
    DraftPick.destroy_all; DraftGameUser.destroy_all; DraftGame.find(1).update(stage: 0, heist: nil)
  end
end