import { Controller } from "@hotwired/stimulus"

// Identifier: shadcnrb--drawer--component
export default class extends Controller {
  static targets = ["content", "backdrop"]

  open() {
    this.contentTarget.dataset.state = "open"
    this.backdropTarget.dataset.state = "open"
    document.body.style.overflow = "hidden"
  }

  close() {
    this.contentTarget.dataset.state = "closed"
    this.backdropTarget.dataset.state = "closed"
    setTimeout(() => {
      document.body.style.overflow = ""
    }, 300)
  }
}
