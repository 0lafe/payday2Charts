import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="leaderboard-index"
export default class extends Controller {
  static targets = ['steamId']

  top100Navigate(e) {
    e.preventDefault()

    window.location.href = `/leaderboards/${this.steamIdTarget.value}/top_100`
  }
}
