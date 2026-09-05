import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["detector"]

  connect() {
    const sidebar = this.element.querySelector("[data-slot='sidebar']")
    this._collapsibleValue =
      sidebar?.dataset?.configuredCollapsible ||
      this.element.dataset.collapsible ||
      "offcanvas"

    if (this._isDesktop()) {
      const stored = document.cookie.match(/(?:^|; )sidebar_state=([^;]*)/)?.[1]
      this._apply(stored === "collapsed" ? "collapsed" : "expanded")
    } else {
      this._apply("collapsed")
    }
  }

  toggle() {
    const next = this.element.dataset.state === "expanded" ? "collapsed" : "expanded"
    this._apply(next)
    if (this._isDesktop()) document.cookie = `sidebar_state=${next};path=/;max-age=${60 * 60 * 24 * 7}`
  }

  _apply(state) {
    this.element.dataset.state = state
    const sidebar = this.element.querySelector("[data-slot='sidebar']")
    if (!sidebar) return
    sidebar.dataset.state = state
    const mode = this._isDesktop() ? this._collapsibleValue : "offcanvas"
    sidebar.dataset.collapsible = state === "collapsed" ? mode : ""
  }

  _isDesktop() {
    if (!this.hasDetectorTarget) return true
    return getComputedStyle(this.detectorTarget).display !== "none"
  }
}
