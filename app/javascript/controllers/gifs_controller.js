import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="gifs"
export default class extends Controller {
  connect() {
    var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
    tooltipTriggerList.map(function (tooltipTriggerEl) {
      return new bootstrap.Tooltip(tooltipTriggerEl)
    })

    $(".gif-title h3").click(function() {
      const link = $(this).find("span").text().replace(/\s+/g, '')
      navigator.clipboard.writeText(link)
    })
  }
}
