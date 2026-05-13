import { Controller } from "@hotwired/stimulus"
import { Chart, registerables } from "chart.js"

// Connects to data-controller="chart-page"
export default class extends Controller {
  static targets = ['label', 'container', 'paginationNumbers']

  static values = {
    stat: {
      type: String, default: "melee_kills"
    },
    perPage: Number,
    pageDisplay: Number,
    currentPage: Number,
    totalPages: Number,
    apiData: {
      type: Object, default: {}
    },
    currentData: Array
  }

  connect() {
    Chart.register(...registerables)
    Chart.defaults.color = 'oklch(70.5% 0.015 286.067)'

    this.setPaginationValues()

    this.createTiles()

    this.handleStatChange()
  }

  setPaginationValues() {
    if (document.documentElement.clientWidth > 1920) {
      this.perPageValue = 8
      this.pageDisplayValue = 5
    } else if (document.documentElement.clientWidth > 768) {
      this.perPageValue = 6
      this.pageDisplayValue = 5
    } else {
      this.perPageValue = 3
      this.pageDisplayValue = 3
    }
  }

  createTiles() {
    for (let i = 1; i < this.perPageValue; i++) {
      const node = this.containerTarget.querySelector('section').cloneNode(true)
      this.containerTarget.appendChild(node)
    }
  }

  async getApiData() {
    const reply = await fetch(`stats/${this.statValue}`)
    const response = await reply.json()

    const data = response.data.map((item, index) => {
      item.position = index + 1

      return item
    })

    this.apiDataValue[this.statValue] = data
  }

  async handleStatChange() {
    if (!this.apiDataValue[this.statValue]) {
      this.containerTarget.querySelectorAll('.loader').forEach(el => {
        el.classList.remove('hidden')
      })
      this.containerTarget.querySelectorAll('.content').forEach(el => {
        el.classList.add('hidden')
      })
      
      await this.getApiData()
      
      this.containerTarget.querySelectorAll('.loader').forEach(el => {
        el.classList.add('hidden')
      })
      this.containerTarget.querySelectorAll('.content').forEach(el => {
        el.classList.remove('hidden')
      })
    }

    this.currentDataValue = this.apiDataValue[this.statValue]

    this.totalPagesValue = Math.ceil(this.currentDataValue.length / this.perPageValue)

    this.handleNavigatePage(0)
  }

  renderCharts() {
    const start = this.currentPageValue * this.perPageValue
    const end = start + this.perPageValue

    const dataSlice = this.currentDataValue.slice(start, end)

    dataSlice.forEach((data, index) => {
      const parent = this.containerTarget.children[index]

      parent.querySelector('.name').innerText = data.localized_name

      const total = data.values.reduce((sum, i) => {return sum + parseInt(i)}, 0).toLocaleString('en-US')
      parent.querySelector('.total').innerText = `Total: ${total}`

      parent.querySelector('.rank').innerText = `#${data.position} Overall`
      
      parent.querySelector('.image').replaceChildren()
      const imgElement = document.createElement('img')
      imgElement.src = data.img_url
      imgElement.classList = "max-h-32 w-auto 3xl:max-h-64"
      parent.querySelector('.image').appendChild(imgElement)

      const chartCanvas = parent.querySelector('canvas')

      const chart = Chart.getChart(chartCanvas)

      if (chart) {
        chart.destroy()
      }

      new Chart(chartCanvas, {
        type: 'line',
        data: {
          labels: data.labels,
          datasets: [{
            label: data.name,
            data: data.values,
            borderWidth: 1
          }]
        },
        options: {
          scales: {
            y: {
              beginAtZero: true,
              max: Math.max(...data.values),
              min: 0
            },
            x: {
              ticks: {
                autoSkip: true,

                minRotation: 0,
                maxRotation: 0
              }
            }
          },
          plugins: {
            legend: {
              display: false
            }
          }
        }
      });
    })

    if (dataSlice.length < this.perPageValue) {
      Array.from(this.containerTarget.children).forEach((el, index) => {
        if (index >= dataSlice.length) {
          el.classList.add('hidden')
        } else {
          el.classList.remove('hidden')
        }
      })
    } else {
      Array.from(this.containerTarget.children).forEach((el, index) => {
        el.classList.remove('hidden')
      })
    }
  }

  navigateStart() {
    this.handleNavigatePage(0)
  }

  navigatePrevious() {
    this.handleNavigatePage(this.currentPageValue - 1)
  }

  navigateNext() {
    this.handleNavigatePage(this.currentPageValue + 1)
  }

  navigateEnd() {
    this.handleNavigatePage(this.totalPagesValue - 1)
  }

  handleNavigatePage(page) {
    this.currentPageValue = page

    this.renderCharts()

    this.constructPagination()
  }

  constructPagination() {
    this.paginationNumbersTarget.replaceChildren()

    for (let i = 0; i < this.totalPagesValue && i < this.pageDisplayValue; i++) {
      const range = (this.pageDisplayValue - 1)/2

      let val = this.currentPageValue - range + i

      let shift = 0

      if (this.currentPageValue <= range) {
        shift += range - this.currentPageValue
      } else if (this.totalPagesValue - this.currentPageValue <= range && this.totalPagesValue > this.pageDisplayValue) {
        shift -= (this.currentPageValue - this.totalPagesValue + range) + 1
      }
      if (val + shift <= this.totalPagesValue) {
        this.addPaginationButton(val + shift)
      }
    }

    Array.from(this.paginationNumbersTarget.children).forEach(el => {
      el.addEventListener('click', e => {
        this.handleNavigatePage(e.currentTarget.dataset.value)
      })
    })

    if (this.currentPageValue === 0) {
      document.querySelectorAll('.paginate-back').forEach(el => {
        el.disabled = true
      })
    } else {
      document.querySelectorAll('.paginate-back').forEach(el => {
        el.disabled = false
      })
    }

    if (this.currentPageValue === (this.totalPagesValue - 1)) {
      document.querySelectorAll('.paginate-forward').forEach(el => {
        el.disabled = true
      })
    } else {
      document.querySelectorAll('.paginate-forward').forEach(el => {
        el.disabled = false
      })
    }
  }

  addPaginationButton(page) {
    const element = document.createElement('button')
    element.innerText = page + 1

    element.dataset.value = page

    element.classList = "pagination-number"
    if (page === this.currentPageValue) {
      element.setAttribute('disabled', true)
    }

    this.paginationNumbersTarget.appendChild(element)
  }

  select(e) {
    this.labelTarget.innerText = e.currentTarget.dataset.label
    this.statValue = e.currentTarget.dataset.value

    this.handleStatChange()
  }

  search(e) {
    const searchString = e.currentTarget.value.toLowerCase()

    this.currentDataValue = this.apiDataValue[this.statValue].filter(item => {
      return item.localized_name.toLowerCase().includes(searchString)
    })

    this.handleNavigatePage(0)
  }
}
