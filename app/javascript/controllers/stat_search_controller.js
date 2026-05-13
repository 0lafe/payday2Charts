import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="stat-search"
export default class extends Controller {
  static targets = ["label"]


  select(e) {
    let route = e.currentTarget.dataset.value
    const grouping = e.currentTarget.dataset.grouping

    if (grouping) {
      route += `?grouping=${grouping}`
    }

    window.location.href = `/leaderboards/${route}`

    this.labelTarget.textContent = "Loading ..."
  }
}
