import { Controller } from "@hotwired/stimulus"

// Identifier: shadcnrb--toast--component
// Attached to a body-level toast element. Auto-dismisses after `duration` ms.
export default class extends Controller {
  static values = { duration: { type: Number, default: 5000 } }

  connect() {
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
