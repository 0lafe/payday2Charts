import { Controller } from "@hotwired/stimulus"
import { Chart, registerables } from "chart.js"

// Connects to data-controller="perkdeck-chart"
export default class extends Controller {
  static values = {
    labels: Array,
    data: Array
  }

  connect() {
    Chart.register(...registerables)
    Chart.defaults.color = 'oklch(70.5% 0.015 286.067)'

    this.chart = new Chart(this.element, {
      type: "pie",
      data: {
        labels: this.labelsValue,
        datasets: [{
          data: this.dataValue
        }]
      }
    })
  }

  disconnect() {
    this.chart?.destroy()
  }
}
