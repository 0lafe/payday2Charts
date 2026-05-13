import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="table-search"
export default class extends Controller {
  static targets = ['search', 'body']

  connect() {
  }

  handleSearch(_) {
    const query = this.searchTarget.value.toLowerCase()

    for (const el of this.bodyTarget.children) {
      const text = el.textContent.toLowerCase()
      el.classList.toggle("hidden", !text.includes(query))
    }
  }
}
