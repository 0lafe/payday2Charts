import { subscribeToDraftGame } from "channels/draft_game_channel"

export default function draftGame({ draftGameId, currentUserId, initialState, assetImages }) {
  return {
    draftGameId,
    currentUserId,
    assetImages,
    state: initialState,
    subscription: null,
    selectedHeist: null,
    selectedPerkdeck: null,
    selectedWeapon: null,
    selectedSkill: null,
    heistSearch: '',

    init() {
      this.assetImages.forEach(url => {
        const image = new Image()
        image.src = url
      })

      this.subscription = subscribeToDraftGame(
        this.draftGameId,
        (data) => {
          this.selectedHeist = null
          this.selectedPerkdeck = null
          this.selectedWeapon = null
          this.selectedSkill = null

          this.state = data
        }
      )
    },

    destroy() {
      this.subscription?.unsubscribe()
    },

    get isMyTurn() {
      if (this.state.stage === 'waiting') {
        return !this.isHost && this.myTeam === null
      } else {
        return this.state.current_turn_user_id === this.currentUserId
      }
    },

    get myTeam() {
      if (this.state.users.team_a.some(user => user.id === this.currentUserId)) {
        return "team_a"
      }

      if (this.state.users.team_b.some(user => user.id === this.currentUserId)) {
        return "team_b"
      }

      return null
    },

    get isHost() {
      return this.state.host_user_id === this.currentUserId
    },

    get isWaitingToStart() {
      return this.state.stage === 'waiting' && !this.isMyTurn
    },

    heistBans(team) {
      return (this.state.draft_picks?.heist?.ban || []).filter((item) => {
        return item.team === team
      })
    },

    perkdeckBans(team) {
      return (this.state.draft_picks?.perkdeck?.ban || []).filter((item) => {
        return item.team === team
      })
    },

    weaponBans(team) {
      return (this.state.draft_picks?.weapon?.ban || []).filter((item) => {
        return item.team === team
      })
    },

    skillBans(team) {
      return (this.state.draft_picks?.skill?.ban || []).filter((item) => {
        return item.team === team
      })
    },

    teamUsers(team) {
      return this.state.users[team]
    },

    perkdeckForUser(id) {
      return (this.state.draft_picks?.perkdeck?.choice || []).find(item => {
        return item.user_id === id
      })
    },

    teamFull(team) {
      return this.teamUsers(team).length >= this.state.players_per_team
    },

    titleize(value) {
      return value
        .replace(/[_-]+/g, ' ')
        .replace(/\b\w/g, char => char.toUpperCase())
    }
  }
}