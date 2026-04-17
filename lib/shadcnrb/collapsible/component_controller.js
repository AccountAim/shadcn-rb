import { Controller } from "@hotwired/stimulus"

// Identifier: shadcnrb--collapsible--component
//
// Tiny toggle: flips `data-state` between open/closed on the root,
// all contentTargets, and any `[data-slot=collapsible-trigger]` descendant.
// CSS selectors (`hidden data-[state=open]:block`) handle show/hide.
export default class extends Controller {
  static targets = ["content"]
  static values = { open: { type: Boolean, default: false } }

  connect() {
    this._apply()
  }

  openValueChanged() {
    this._apply()
  }

  toggle() {
    this.openValue = !this.openValue
  }

  _apply() {
    const state = this.openValue ? "open" : "closed"
    this.element.dataset.state = state
    this.contentTargets.forEach(t => { t.dataset.state = state })
    this.element.querySelectorAll('[data-action*="shadcnrb--collapsible--component#toggle"]').forEach(t => {
      t.setAttribute("aria-expanded", this.openValue.toString())
    })
  }
}
