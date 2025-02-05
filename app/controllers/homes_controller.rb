class HomesController < ApplicationController

  def index
    @options = [
      ['Melee Kills', 'melee_kills'],
      ['Melee Usage', 'melee_used'],
      ['Weapon Kills', 'weapon_kills'],
      ['Weapon Usage', 'weapon_used'],
      ['Weapon Shots', 'weapon_shots'],
      ['Weapon Hits', 'weapon_hits'],
      ['Weapon Charm Usage ', 'weapon_charm_used'],
      ['Weapon Color Usage ', 'weapon_color_used'],
      ['Mask Usage', 'mask_used'],
      ['Glove Usage', 'gloves_used'],
      ['Outfit Usage', 'suit_used'],
      ['Heist Data ', 'contract'],
      ['Armor Used ', 'armor_used'],
      ['Perkdeck Used ', 'specialization_used'],
      ['Throwable Kills', 'grenade_kills'],
      ['Throwable Usage', 'grenade_used'],
      ['Deployable Usage', 'gadget_used'],
      ['Difficulties Played', 'difficulty'],
      ['Heister Used ', 'character_used'],
      ['Enemies Killed ', 'enemy_kills'],
      ['Player Info ', 'info_playing'],
      ['Player Ranks ', 'player_rank'],
      ['Player Time ', 'player_time'],
      ['Player Level ', 'player_level'],
      ['Player Cash ', 'player_cash'],
      ['Player Coins ', 'player_coins'],
      ['Skills ', 'skill_'],
      ['Kick Method ', 'option_decide']
    ]
  end

end
