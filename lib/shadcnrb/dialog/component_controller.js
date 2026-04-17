import { Controller } from "@hotwired/stimulus"

// Identifier: shadcnrb--dialog--component
export default class extends Controller {
  static targets = ["content", "backdrop"]
  static values = { open: { type: Boolean, default: false } }

  connect() {
    if (this.openValue) this.open()
  }

  open() {
    this.openValue = true
    this.contentTarget.dataset.state = "open"
    this.backdropTarget.dataset.state = "open"
    document.body.style.overflow = "hidden"

    // Lazy-load: if a turbo-frame inside has data-lazy-src but no src yet, trigger it
    const frame = this.contentTarget.querySelector("turbo-frame[data-lazy-src]")
    if (frame && !frame.getAttribute("src")) {
      frame.setAttribute("src", frame.dataset.lazySrc)
    }
  }

  close() {
    this.openValue = false
    this.contentTarget.dataset.state = "closed"
    this.backdropTarget.dataset.state = "closed"
    setTimeout(() => {
      document.body.style.overflow = ""
    }, 200)

    // If reload mode, clear the frame src so the next open re-fetches
    const frame = this.contentTarget.querySelector("turbo-frame[data-lazy-reload]")
    if (frame) {
      frame.removeAttribute("src")
      // Restore the loading placeholder if one was stashed
      if (frame.dataset.loadingHtml) {
        frame.innerHTML = frame.dataset.loadingHtml
      }
    }
  }

  keydown(event) {
    if (event.key === "Escape" && this.openValue) this.close()
  }

  toggle() {
    this.openValue ? this.close() : this.open()
  }
}
