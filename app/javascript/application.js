// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "chart.js"
import "channels"

import Alpine from "alpinejs"
import draftGame from "components/draft_game"

Alpine.data("draftGame", draftGame)

window.Alpine = Alpine

Alpine.start()
