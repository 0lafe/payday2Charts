import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="stat-search"
export default class extends Controller {
  static targets = ["label"]


  select(e) {
    let route = e.currentTarget.dataset.value
    const filter = e.currentTarget.dataset.filter

    if (filter) {
      route += `?filter=${filter}`
    }

    window.location.href = `/leaderboards/${route}`

    this.labelTarget.textContent = "Loading ..."
  }
}
