import { subscribeToDraftGame } from "channels/draft_game_channel"

export default function draftGame({ draftGameId, currentUserId, initialState, heistImages }) {
  return {
    draftGameId,
    currentUserId,
    heistImages,
    state: initialState,
    subscription: null,
    selectedHeist: null,
    selectedPerkdeck: null,
    selectedWeapon: null,

    init() {
      this.heistImages.forEach(url => {
        const image = new Image()
        image.src = url
      })

      this.subscription = subscribeToDraftGame(
        this.draftGameId,
        (data) => {
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
      if (this.state.team_a_user_ids.includes(this.currentUserId)) {
        return "team_a"
      }

      if (this.state.team_b_user_ids.includes(this.currentUserId)) {
        return "team_b"
      }

      return null
    },

    get isHost() {
      return this.state.host_user_id === this.currentUserId
    },

    updateState(state) {
      this.state = state
    }
  }
}