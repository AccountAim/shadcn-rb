import AnchoredController from "controllers/shadcnrb/anchored/component_controller"

// Identifier: shadcnrb--navigation-menu--component
//
// One controller per menu on top of the shared anchored engine (which owns
// panel placement, top-layer display, flip/shift, and scroll tracking).
// `openValue` holds the open item's nav-value (empty = closed), so opening
// one trigger's content closes any other; each panel anchors to the trigger
// with the matching `data-nav-value`. `close` gives a grace period so the
// pointer can travel from trigger to content without gap-closing.
export default class extends AnchoredController {
  static targets = ["trigger", "content"]
  static values = {
    open: String,
    closeDelay: { type: Number, default: 150 }
  }

  connect() {
    super.connect()
    this._clickOutside = this.clickOutside.bind(this)
    document.addEventListener("click", this._clickOutside, true)
  }

  disconnect() {
    document.removeEventListener("click", this._clickOutside, true)
    super.disconnect()
  }

  open(event) {
    clearTimeout(this.timer)
    this.openValue = event.currentTarget.dataset.navValue
  }

  toggle(event) {
    clearTimeout(this.timer)
    const value = event.currentTarget.dataset.navValue
    this.openValue = this.openValue === value ? "" : value
  }

  close() {
    clearTimeout(this.timer)
    this.timer = setTimeout(() => { this.openValue = "" }, this.closeDelayValue)
  }

  cancelClose() {
    clearTimeout(this.timer)
  }

  dismiss() {
    clearTimeout(this.timer)
    this.openValue = ""
  }

  clickOutside(event) {
    if (this.openValue && !this.element.contains(event.target)) this.dismiss()
  }

  sync() {
    const open = this.openValue || ""
    this.triggerTargets.forEach(el => {
      const match = el.dataset.navValue === open
      el.dataset.state = match ? "open" : "closed"
      el.setAttribute("aria-expanded", String(match))
    })
    this.contentTargets.forEach(panel =>
      this.apply(panel, panel.dataset.navValue === open))
  }

  anchorFor(panel) {
    return this.triggerTargets.find(t => t.dataset.navValue === panel.dataset.navValue) ||
      this.element
  }
}
