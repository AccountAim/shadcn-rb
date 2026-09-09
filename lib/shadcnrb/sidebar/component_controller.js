import { Controller } from "@hotwired/stimulus"

const DESKTOP = window.matchMedia("(min-width: 768px)")

export default class extends Controller {
  static targets = ["detector", "flyout"]
  // The desktop state as rendered (cookie or the host's `state:`); the
  // pre-paint init script rewrites data-state on mobile but not this.
  static values = { state: { type: String, default: "expanded" } }

  connect() {
    const sidebar = this.element.querySelector("[data-slot='sidebar']")
    this._collapsibleValue =
      sidebar?.dataset?.configuredCollapsible ||
      this.element.dataset.collapsible ||
      "offcanvas"
    this._restore = this.restore.bind(this)
    DESKTOP.addEventListener("change", this._restore)
    this.restore()
  }

  disconnect() {
    DESKTOP.removeEventListener("change", this._restore)
  }

  // Desktop follows the rendered state in the configured mode; mobile is
  // always a closed offcanvas drawer. Runs on connect and whenever the
  // viewport crosses the breakpoint, so a drawer left open never survives a
  // resize.
  restore() {
    this._apply(this._isDesktop() ? this.stateValue : "collapsed")
  }

  // Only a desktop toggle is a preference worth keeping: the cookie, the
  // value, and a `change` event for the host to store.
  toggle() {
    const next = this.element.dataset.state === "expanded" ? "collapsed" : "expanded"
    this._apply(next)
    if (!this._isDesktop()) return

    this.stateValue = next
    document.cookie = `sidebar_state=${next};path=/;max-age=${60 * 60 * 24 * 7}`
    this.dispatch("change", { detail: { state: next } })
  }

  _apply(state) {
    this.element.dataset.state = state
    const sidebar = this.element.querySelector("[data-slot='sidebar']")
    if (!sidebar) return
    sidebar.dataset.state = state
    const mode = this._isDesktop() ? this._collapsibleValue : "offcanvas"
    sidebar.dataset.collapsible = state === "collapsed" ? mode : ""
    // Sub-menu flyouts (`s.collapsible flyout: true`) only make sense on the
    // icon rail; the hover card releases its panel when disabled.
    const flyouts = state === "collapsed" && mode === "icon"
    this.flyoutTargets.forEach(el =>
      el.setAttribute("data-shadcnrb--anchored--component-enabled-value", flyouts))
  }

  _isDesktop() {
    if (!this.hasDetectorTarget) return true
    return getComputedStyle(this.detectorTarget).display !== "none"
  }
}
