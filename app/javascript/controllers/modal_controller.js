import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="modal"
export default class extends Controller {
  static targets = ["container"]

  open() {
    this.containerTarget.classList.add("in")
  }

  close() {
    this.containerTarget.classList.remove("in")
  }
}
