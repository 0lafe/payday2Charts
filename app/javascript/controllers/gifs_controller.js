import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="gifs"
export default class extends Controller {
  connect() {
    var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
    tooltipTriggerList.map(function (tooltipTriggerEl) {
      return new bootstrap.Tooltip(tooltipTriggerEl)
    })
  
    $('.gif-link').on('click', (e) => {
      const link = $(`#gif-link-${e.target.dataset.id}`)
      navigator.clipboard.writeText(link.text())
    })
  }
}
