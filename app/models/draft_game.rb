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
    skill_bans: 6,
    finish: 7,
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
      .sort_by(&:id)
      .first
      &.user
  end

  def turn_team(pick_count)
    if ((pick_count + 1) / 2).even?
      "team_a"
    else
      "team_b"
    end
  end

  def pick_count(draft_type, draft_target)
    draft_picks
      .where(draft_type:, draft_target:)
      .count
  end

  def current_turn_user
    case stage
    when "heist_bans"
      team = turn_team(
        pick_count("ban", "heist")
      )

      team_captain(team)
    when "perk_bans"
      team = turn_team(
        pick_count("ban", "perkdeck")
      )

      team_captain(team)
    when "perk_choices"
      choice_count = pick_count("choice", "perkdeck")
      team = turn_team(choice_count)

      player = choice_count / 2

      draft_game_users
        .where(team:)
        .sort_by(&:id)[player]&.user
    when "weapon_bans"
      team = turn_team(
        pick_count("ban", "weapon")
      )

      team_captain(team)
    when "skill_bans"
      team = turn_team(
        pick_count("ban", "skill")
      )

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
    base_heists - draft_picks.ban.heist.map(&:name)
  end

  def available_perkdecks
    base_perkdecks - draft_picks.perkdeck.map(&:name)
  end

  def available_weapons
    base_weapons - draft_picks.weapon.map(&:name)
  end

  def available_skills
    base_skills - draft_picks.skill.map(&:name)
  end

  def team_user_data(team)
    draft_game_users
      .where(team:)
      .map {|game_user| {
        id: game_user.user.id,
        avatar: game_user.user.avatar,
        name: game_user.user.name,
      } }
  end

  def heist_url
    if heist
      ActionController::Base.helpers.asset_path("heists/named/#{heist}.png")
    end
  end

  def draft_pick_data
    draft_picks.includes(:draft_game_user).map { |draft_pick|
      {
        user_id: draft_pick.draft_game_user.user_id,
        draft_type: draft_pick.draft_type,
        draft_target: draft_pick.draft_target,
        name: draft_pick.name,
        team: draft_pick.draft_game_user.team,
        image: draft_pick.image
      }
    }
    .group_by { |item| item[:draft_target] }
    .transform_values do |type_items|
      type_items.group_by { |item| item[:draft_type] }
    end
  end

  def client_state
    {
      stage:,
      players_per_team:,
      current_turn_user_id: current_turn_user&.id,
      host_user_id: user.id,
      users: {
        team_a: team_user_data("team_a"),
        team_b: team_user_data("team_b"),
      }, 
      available_heists:,
      available_perkdecks:,
      available_weapons:,
      available_skills:,
      heist: heist_url,
      draft_picks: draft_pick_data
    }
  end

  def set_heist
    update(heist: available_heists.sample)

    winning_index = 30 + rand(20)

    heists = available_heists
    heists = Array.new(winning_index + 10) do |i|
      heists.sample
    end

    heists[winning_index] = heist

    heists.map! do |heist|
      ActionController::Base.helpers.asset_path("heists/named/#{heist}.png")
    end

    self.broadcast_update_to(
      self,
      target: 'showoff-area',
      partial: "draft_games/showoff/heist_select",
      locals: {
        heists:,
        winning_index:,
        heist: heist.titleize
      }
    )
  end

  def total_players_max
    players_per_team * 2
  end

  def set_stage
    case stage
    when "waiting"
      if draft_game_users.count >= total_players_max
        update_column("stage", "heist_bans")
      end
    when "heist_bans"
      if draft_picks.ban.heist.count >= heist_ban_count * 2
        update_column("stage", "heist_select")

        AdvanceDraftGameHeistSelectJob
          .set(wait: 5.second)
          .perform_later(id)
      end
    when "perk_bans"
      if draft_picks.ban.perkdeck.count >= perkdeck_ban_count * 2
        update_column("stage", "perk_choices")
      end
    when "perk_choices"
      if draft_picks.choice.perkdeck.count >= total_players_max
        update_column("stage", "weapon_bans")
      end
    when "weapon_bans"
      if draft_picks.ban.weapon.count >= weapon_ban_count * 2
        update_column("stage", "skill_bans")
      end
    when "skill_bans"
      if draft_picks.ban.skill.count >= skill_ban_count * 2
        update_column("stage", "finish")
      end
    end
  end

  def association_updated
    set_stage

    update_interaction_area
  end

  def self.reset_all
    DraftPick.destroy_all; DraftGameUser.destroy_all; DraftGame.update_all(stage: 0, heist: nil)
  end
end