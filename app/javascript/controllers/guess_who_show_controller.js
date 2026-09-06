import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="guess-who-show"
export default class extends Controller {
  static targets = ['yourCard']

  static values = {
    gameType: String
  }

  connect() {
    this.setSelectedCard()
  }

  reset() {
    this.setSelectedCard()

    document.querySelectorAll(".gameplay-item").forEach((element) => {
      element.classList.remove("brightness-50")
    })
  }

  setSelectedCard() {
    const imageContainers = document.getElementsByClassName("gameplay-item")

    const chosenImage = imageContainers[Math.floor(Math.random() * imageContainers.length)].children[0]
    const imageSource = chosenImage.src
    
    this.yourCardTarget.src = imageSource

    if (this.gameTypeValue === 'skins') {
      this.yourCardTarget.classList = chosenImage.classList
    }
  }

  flip(e) {
    e.currentTarget.classList.toggle('brightness-50')
  }

  copyLink(e) {
    const link = e.currentTarget.dataset.link
    navigator.clipboard.writeText(link)
  }
}
