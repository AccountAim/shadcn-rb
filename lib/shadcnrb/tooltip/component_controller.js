import { Controller } from "@hotwired/stimulus"

// Identifier: shadcnrb--tooltip--component
//
// Hover / focus opener with open + close delays. Flips `data-state` on the
// root and every content target; CSS (`hidden data-[state=open]:block`)
// handles visibility and placement — no floating-ui.
let uid = 0

export default class extends Controller {
  static targets = ["content"]
  static values = {
    delay: { type: Number, default: 0 },
    closeDelay: { type: Number, default: 0 },
    open: { type: Boolean, default: false }
  }

  connect() {
    this.timer = null
    this.describe()
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

  // Wiring aria-describedby server-side would mean threading a unique id
  // through every call site; the pair is always in one controller, so mint it
  // here instead. Without an explicit trigger slot (the wrapper form, where
  // the trigger is whatever the caller rendered) the first child is it.
  describe() {
    const trigger = this.element.querySelector('[data-slot="tooltip-trigger"]') ||
      this.element.firstElementChild
    const content = this.contentTargets[0]
    if (!trigger || !content) return
    if (!content.id) content.id = `shadcnrb-tooltip-${++uid}`
    trigger.setAttribute("aria-describedby", content.id)
  }
}
