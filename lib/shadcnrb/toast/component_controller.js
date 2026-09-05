import { Controller } from "@hotwired/stimulus"

// Identifier: shadcnrb--toast--component
// Attached to a toast inside the toaster. Slides in on connect and
// auto-dismisses after `duration` ms.
export default class extends Controller {
  static values = { duration: { type: Number, default: 5000 } }

  connect() {
    this.element.style.opacity = "0"
    this.element.style.transform = "translateX(1rem)"
    requestAnimationFrame(() => {
      this.element.style.transition = "opacity .25s ease, transform .25s ease"
      this.element.style.opacity = "1"
      this.element.style.transform = "translateX(0)"
    })
    this.timeout = setTimeout(() => this.dismiss(), this.durationValue)
  }

  disconnect() {
    if (this.timeout) clearTimeout(this.timeout)
  }

  dismiss() {
    this.element.style.opacity = "0"
    this.element.style.transform = "translateX(100%)"
    setTimeout(() => this.element.remove(), 300)
  }
}
