import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="guess-who-show"
export default class extends Controller {
  flip(e) {
    e.currentTarget.classList.toggle('brightness-50')
  }
}
