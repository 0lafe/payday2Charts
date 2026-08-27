// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "chart.js"
import "channels"

import Alpine from "alpinejs"
import draftGame from "components/draft_game"
import draftGameStreamer from "components/draft_game_streamer"
import itemRoller from "components/item_roller"
import showoffContent from "components/showoff_content"

Alpine.data("draftGame", draftGame)
Alpine.data("draftGameStreamer", draftGameStreamer)
Alpine.data("itemRoller", itemRoller)
Alpine.data("showoffContent", showoffContent)

window.Alpine = Alpine

Alpine.start()
