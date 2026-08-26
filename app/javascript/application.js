// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "chart.js"
import "channels"

import Alpine from "alpinejs"
import draftGame from "components/draft_game"
import itemRoller from "components/item_roller"

Alpine.data("draftGame", draftGame)
Alpine.data("itemRoller", itemRoller)

window.Alpine = Alpine

Alpine.start()
