import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dropdown"
export default class extends Controller {
  static targets = ["menu"]

  connect() {
    this.open = false
    this.handleOutsideClick = this.handleOutsideClick.bind(this)
  }

  toggle() {
    this.open ? this.close() : this.openMenu()
  }

  openMenu() {
    this.menuTarget.classList.remove("hidden")
    this.open = true

    document.addEventListener("click", this.handleOutsideClick)
  }

  close() {
    this.menuTarget.classList.add("hidden")
    this.open = false

    document.removeEventListener("click", this.handleOutsideClick)
  }

  handleOutsideClick(e) {
    if (!this.element.contains(e.target)) {
      this.close()
    }
  }
}
