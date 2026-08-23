import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="draft-game-index"
export default class extends Controller {
  checkAll(event) {
    this.setCheckboxes(event, true)
  }

  checkNone(event) {
    this.setCheckboxes(event, false)
  }

  setCheckboxes(event, checked) {
    const group = event.currentTarget.closest(
      '[data-checkbox-group-target="group"]'
    )

    group
      .querySelectorAll('input[type="checkbox"]')
      .forEach((checkbox) => {
        checkbox.checked = checked
      })
  }
}
