import consumer from "channels/consumer"

export function subscribeToDraftGame(draftGameId, received) {
  return consumer.subscriptions.create(
    {
      channel: "DraftGameChannel",
      id: draftGameId
    },
    {
      connected() {
        console.log("Connected to draft game", draftGameId)
      },

      disconnected() {
        console.log("Disconnected from draft game", draftGameId)
      },

      received(data) {
        received(data)
      }
    }
  )
}