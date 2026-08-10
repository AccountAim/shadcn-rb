import { Controller } from "@hotwired/stimulus"

// Identifier: shadcnrb--hover-card--component
//
// Hover / focus opener with open + close delays. Flips `data-state` on the
// root and every content target; CSS (`hidden data-[state=open]:block`)
// handles visibility and placement — no floating-ui.
//
// The close delay doubles as the grace period for the pointer crossing the
// gap between trigger and panel: leaving fires `close`, re-entering cancels
// the pending timer.
export default class extends Controller {
  static targets = ["content"]
  static values = {
    delay: { type: Number, default: 600 },
    closeDelay: { type: Number, default: 300 },
    open: { type: Boolean, default: false }
  }

  connect() {
    this.timer = null
    this.sync()
  }

  disconnect() {
    clearTimeout(this.timer)
  }

  open() {
    clearTimeout(this.timer)
    if (this.openValue) return
    this.timer = setTimeout(() => { this.openValue = true }, this.delayValue)
  }

  close() {
    clearTimeout(this.timer)
    if (!this.openValue) return
    this.timer = setTimeout(() => { this.openValue = false }, this.closeDelayValue)
  }

  dismiss() {
    clearTimeout(this.timer)
    this.openValue = false
  }

  openValueChanged() {
    this.sync()
  }

  sync() {
    const state = this.openValue ? "open" : "closed"
    this.element.dataset.state = state
    this.contentTargets.forEach(t => { t.dataset.state = state })
  }
}
