import { subscribeToDraftGame } from "channels/draft_game_channel"

export default function draftGame({ draftGameId, currentUserId, initialState }) {
  return {
    draftGameId,
    currentUserId,
    state: initialState,
    subscription: null,

    init() {
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
      return this.state.current_turn_user_id === this.currentUserId
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

    get isInGame() {
      return this.myTeam !== null
    },

    get isHost() {
        return this.state.host_user_id === this.currentUserId
    },

    updateState(state) {
      this.state = state
    }
  }
}