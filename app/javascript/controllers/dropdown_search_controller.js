import { Controller } from "@hotwired/stimulus"
import Fuse from "fuse.js"

// Connects to data-controller="dropdown-search"
export default class extends Controller {
  static targets = ["menu", "item", "input", "button"]

  connect() {
    this.items = this.itemTargets.map((element) => ({
      element,
      text: this.normalize(element.textContent)
    }))

    this.fuse = new Fuse(this.items, {
      keys: ["text"],
      threshold: 0.2,
      ignoreLocation: true
    })
  }

  toggle() {
    this.menuTarget.classList.toggle("hidden")
    this.buttonTarget.classList.toggle("rounded-b-xl")

    if (!this.menuTarget.classList.contains("hidden")) {
      this.inputTarget.focus()
    }
  }

  filter() {
    const query = this.normalize(this.inputTarget.value)

    if (!query) {
      this.itemTargets.forEach((el) => el.classList.remove("hidden"))
      return
    }

    const exactMatches = this.items.filter((item) =>
      item.text.includes(query)
    )

    const fuzzyMatches = this.fuse.search(query).map((result) => result.item)

    const matches = new Set([
      ...exactMatches.map((item) => item.element),
      ...fuzzyMatches.map((item) => item.element)
    ])

    this.itemTargets.forEach((el) => {
      el.classList.toggle("hidden", !matches.has(el))
    })
  }

  normalize(value) {
    return value
      .normalize("NFD")
      .replace(/\p{Diacritic}/gu, "")
      .toLowerCase()
      .trim()
  }
}
