import consumer from "channels/consumer"

export function subscribeToDraftGame(draftGameId, received) {
  return consumer.subscriptions.create(
    {
      channel: "DraftGameChannel",
      id: draftGameId
    },
    
    {
      received(data) {
        received(data)
      }
    }
  )
}