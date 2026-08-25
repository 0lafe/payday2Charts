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
      .select {|user| user.team == team }
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

  def current_turn_user
    case stage
    when "heist_bans"
      ban_count = draft_picks.select {|pick| pick.draft_type == "ban" && pick.draft_target == "heist" }.count
      team = turn_team(ban_count)

      team_captain(team)
    when "perk_bans"
      ban_count = draft_picks.select {|pick| pick.draft_type == "ban" && pick.draft_target == "perkdeck" }.count
      team = turn_team(ban_count)

      team_captain(team)
    when "perk_choices"
      choice_count = draft_picks.select {|pick| pick.draft_type == "choice" && pick.draft_target == "perkdeck" }.count
      team = turn_team(choice_count)

      player = choice_count / 2

      draft_game_users.select {|user| user.team == team }.sort_by(&:id)[player]&.user
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

  def team_user_data(team)
    draft_game_users
      .select {|game_user| game_user.team == team }
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
      current_turn_user_id: current_turn_user&.id,
      host_user_id: user.id,
      users: {
        team_a: team_user_data("team_a"),
        team_b: team_user_data("team_b"),
      }, 
      available_heists:,
      available_perkdecks:,
      available_weapons:,
      heist: heist_url,
      draft_picks: draft_pick_data
    }
  end

  def set_heist
    update(heist: available_heists.sample)

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