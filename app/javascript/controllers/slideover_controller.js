import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="slideover"
export default class extends Controller {
  static targets = ["panel", "backdrop"]

  connect() {
    this.handleOutsideClick = this.handleOutsideClick.bind(this)
  }

  open() {
    this.panelTarget.classList.remove("-translate-x-full")
    this.backdropTarget.classList.remove("hidden")

    document.addEventListener("click", this.handleOutsideClick)
  }

  close() {
    this.panelTarget.classList.add("-translate-x-full")
    this.backdropTarget.classList.add("hidden")

    document.removeEventListener("click", this.handleOutsideClick)
  }

  handleOutsideClick(e) {
    if (this.backdropTarget.contains(e.target)) {
      this.close()
    }
  }
}
