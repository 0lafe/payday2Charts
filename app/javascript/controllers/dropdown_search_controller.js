import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dropdown-search"
export default class extends Controller {
  static targets = ["menu", "item", "input", "button"]

  toggle() {
    this.menuTarget.classList.toggle("hidden")
    this.buttonTarget.classList.toggle("rounded-b-xl")

    if (!this.menuTarget.classList.contains("hidden")) {
      this.inputTarget.focus()
    }
  }

  filter() {
    const query = this.inputTarget.value.toLowerCase()

    this.itemTargets.forEach((el) => {
      const text = el.textContent.toLowerCase()
      el.classList.toggle("hidden", !text.includes(query))
    })
  }
}
