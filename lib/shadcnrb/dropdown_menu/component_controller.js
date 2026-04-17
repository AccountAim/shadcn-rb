import { Controller } from "@hotwired/stimulus"

// Identifier: shadcnrb--dropdown-menu--component
//
// Minimal collision handling: on open, measure the panel and if it would
// overflow the viewport, flip/shift via inline styles. Not full Floating UI —
// just enough so dropdowns near edges stay on-screen.
const EDGE_PAD = 8
const CLOSE_DELAY_MS = 150

export default class extends Controller {
  static targets = ["content"]
  static values = { open: { type: Boolean, default: false } }

  connect() {
    this.closeTimer = null
    this._clickOutside = this.clickOutside.bind(this)
    document.addEventListener("click", this._clickOutside)
  }

  disconnect() {
    clearTimeout(this.closeTimer)
    document.removeEventListener("click", this._clickOutside)
  }

  toggle() {
    this.openValue ? this.close() : this.open()
  }

  open() {
    // Cancel self + every ancestor's close timer so the whole nested stack
    // stays visible — Radix keeps outer menus open when a sub is active.
    this.cancelClose()
    this.openValue = true
    this.contentTarget.dataset.state = "open"
    // Wait a frame so the panel is laid out before we measure.
    requestAnimationFrame(() => this._reposition())
  }

  // Hover-open for sub-menus. Same as `open` but doesn't toggle.
  openOnHover() {
    this.open()
  }

  // Hover from trigger/content starts a close timer; `cancelClose` (fired by
  // mouseenter on the content) clears it so the pointer can travel across the
  // small gap between trigger and content without gap-closing.
  scheduleClose() {
    clearTimeout(this.closeTimer)
    this.closeTimer = setTimeout(() => this.close(), CLOSE_DELAY_MS)
  }

  cancelClose() {
    clearTimeout(this.closeTimer)
    // Walk up and cancel every ancestor's close timer too — when the pointer
    // enters a nested sub, the outer menus must stay open, not just the sub.
    const parent = this.element.parentElement?.closest('[data-controller~="shadcnrb--dropdown-menu--component"]')
    if (!parent) return
    const ctrl = this.application.getControllerForElementAndIdentifier(parent, "shadcnrb--dropdown-menu--component")
    ctrl?.cancelClose()
  }

  close() {
    clearTimeout(this.closeTimer)
    this.openValue = false
    if (this.hasContentTarget) {
      this.contentTarget.dataset.state = "closed"
      // Clear any inline repositioning so the next open starts from CSS defaults.
      const s = this.contentTarget.style
      s.left = s.right = s.top = s.bottom = s.marginTop = s.marginBottom = ""
      this.contentTarget.dataset.side = ""
    }
  }

  // Selecting an item closes this menu AND every ancestor dropdown menu,
  // matching Radix behaviour — otherwise a click inside a sub would leave
  // the outer menu stuck open.
  closeAll() {
    this.close()
    const parent = this.element.parentElement?.closest('[data-controller~="shadcnrb--dropdown-menu--component"]')
    if (!parent) return
    const ctrl = this.application.getControllerForElementAndIdentifier(parent, "shadcnrb--dropdown-menu--component")
    ctrl?.closeAll()
  }

  clickOutside(event) {
    if (this.openValue && !this.element.contains(event.target)) {
      this.close()
    }
  }

  _reposition() {
    if (!this.hasContentTarget) return
    const panel = this.contentTarget
    // Sub-menus anchor left/right of the parent item, not above/below a
    // trigger — the main dropdown's vertical flip logic mis-positions them.
    // TODO: add horizontal flip for subs near the viewport right edge.
    if (panel.dataset.slot === "dropdown-menu-sub-content") return
    const vw = window.innerWidth
    // Nearest `overflow: hidden` ancestor clips us before the viewport does
    // — critical for triggers inside a sidebar footer where the wrapper has
    // `overflow-hidden` and the panel would visually vanish without a flip.
    const clipBottom = this._clipBottom()

    const r1 = panel.getBoundingClientRect()
    if (r1.right > vw - EDGE_PAD) {
      panel.style.right = "0"
      panel.style.left = "auto"
    } else if (r1.left < EDGE_PAD) {
      panel.style.left = "0"
      panel.style.right = "auto"
    }

    const r2 = panel.getBoundingClientRect()
    if (r2.bottom > clipBottom - EDGE_PAD) {
      panel.style.top = "auto"
      panel.style.bottom = "100%"
      panel.style.marginTop = "0"
      panel.style.marginBottom = "0.5rem"
      panel.dataset.side = "top"
    } else {
      panel.dataset.side = "bottom"
    }
  }

  _clipBottom() {
    let bottom = window.innerHeight
    let el = this.element.parentElement
    while (el && el !== document.body) {
      const o = getComputedStyle(el)
      if (o.overflow === "hidden" || o.overflowY === "hidden" || o.overflowY === "clip" || o.overflow === "clip") {
        bottom = Math.min(bottom, el.getBoundingClientRect().bottom)
      }
      el = el.parentElement
    }
    return bottom
  }
}
