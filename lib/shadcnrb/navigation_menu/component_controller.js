// shadcn divergence: vanilla Stimulus controller in place of Radix
// NavigationMenu's React context. Single `openValue` per menu — opening one
// trigger's content closes any other. `scheduleClose` gives a 150ms grace
// period so the pointer can travel from trigger to content without gap-closing.
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values  = { open: String }
  static targets = ["trigger", "content"]

  connect() {
    this.closeTimer = null
    this.boundDocClick = this.onDocumentClick.bind(this)
    document.addEventListener("click", this.boundDocClick, true)
    this.sync()
  }

  disconnect() {
    clearTimeout(this.closeTimer)
    document.removeEventListener("click", this.boundDocClick, true)
  }

  open(event) {
    const value = event.currentTarget.dataset.navValue
    clearTimeout(this.closeTimer)
    this.openValue = value
  }

  toggle(event) {
    const value = event.currentTarget.dataset.navValue
    clearTimeout(this.closeTimer)
    this.openValue = this.openValue === value ? "" : value
  }

  cancelClose() {
    clearTimeout(this.closeTimer)
  }

  scheduleClose() {
    clearTimeout(this.closeTimer)
    this.closeTimer = setTimeout(() => { this.openValue = "" }, 150)
  }

  openValueChanged() {
    this.sync()
  }

  sync() {
    const open = this.openValue || ""
    this.triggerTargets.forEach(el => {
      const match = el.dataset.navValue === open
      el.dataset.state = match ? "open" : "closed"
      el.setAttribute("aria-expanded", match ? "true" : "false")
    })
    this.contentTargets.forEach(el => {
      const match = el.dataset.navValue === open
      el.dataset.state = match ? "open" : "closed"
    })
  }

  onDocumentClick(event) {
    if (!this.element.contains(event.target)) {
      clearTimeout(this.closeTimer)
      this.openValue = ""
    }
  }
}
