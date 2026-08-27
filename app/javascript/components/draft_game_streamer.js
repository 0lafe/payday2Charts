import { subscribeToDraftGame } from "channels/draft_game_channel"

export default function draftGameStreamer({ draftGameId, initialState }) {
  return {
    draftGameId,
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

    teamUsers(team) {
      return this.state.users[team]
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
  }
}