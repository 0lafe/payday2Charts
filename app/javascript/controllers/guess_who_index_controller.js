import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="guess-who-index"
export default class extends Controller {
  static targets = ['newGameForm', 'joinCode']

  join(e) {
    e.preventDefault()
    window.location.href = `guess_whos/${this.joinCodeTarget.value}`
  }

  showForm() {
    this.newGameFormTarget.classList.remove('hidden')
  }
}
