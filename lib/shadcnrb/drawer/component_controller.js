import { Controller } from "@hotwired/stimulus"

// Identifier: shadcnrb--drawer--component
//
// Backdrop and panel open as top-layer popovers so no ancestor transform,
// filter or overflow can box them in.
export default class extends Controller {
  static targets = ["content", "backdrop"]
  static values = { open: { type: Boolean, default: false } }

  connect() {
    if (this.openValue) this.open()
    this._openerClick = this.openerClick.bind(this)
    document.addEventListener("click", this._openerClick)
  }

  disconnect() {
    document.removeEventListener("click", this._openerClick)
    this.hidePopovers()
  }

  // Detached triggers: any element with data-drawer="<this drawer's id>"
  // opens it from anywhere in the document (`sui.button ..., drawer: "id"`).
  openerClick(event) {
    if (!this.element.id) return
    const ref = event.target.closest("[data-drawer]")
    if (!ref || ref.dataset.drawer !== this.element.id || this.element.contains(ref)) return
    event.preventDefault() // a link trigger opens the drawer instead of navigating
    this.open()
  }

  // Bound on the root so the trigger slot's markup stays untouched; clicks
  // inside the panel or backdrop don't count as the trigger. For composite
  // triggers, mark the opening element data-slot="drawer-trigger" — then
  // only it opens.
  open(event) {
    if (event) {
      const t = event.target
      if (this.contentTarget.contains(t) || this.backdropTarget.contains(t)) return
      const marked = [...this.element.querySelectorAll('[data-slot="drawer-trigger"]')]
        .filter(el => !this.contentTarget.contains(el))
      if (marked.length && !marked.some(el => el.contains(t))) return
    }
    this.openValue = true
    this.showPopovers()
    // A frame later, so the open transition starts from the closed pose.
    requestAnimationFrame(() => {
      this.contentTarget.dataset.state = "open"
      this.backdropTarget.dataset.state = "open"
    })
    document.body.style.overflow = "hidden"

    // Lazy-load: if a turbo-frame inside has data-lazy-src but no src yet, trigger it
    const frame = this.contentTarget.querySelector("turbo-frame[data-lazy-src]")
    if (frame && !frame.getAttribute("src")) {
      frame.setAttribute("src", frame.dataset.lazySrc)
    }
  }

  close() {
    this.openValue = false
    this.contentTarget.dataset.state = "closed"
    this.backdropTarget.dataset.state = "closed"
    setTimeout(() => {
      document.body.style.overflow = ""
      this.hidePopovers() // after the close transition
    }, 300)

    // If reload mode, clear the frame src so the next open re-fetches
    const frame = this.contentTarget.querySelector("turbo-frame[data-lazy-reload]")
    if (frame) {
      frame.removeAttribute("src")
      if (frame.dataset.loadingHtml) {
        frame.innerHTML = frame.dataset.loadingHtml
      }
    }
  }
  showPopovers() {
    for (const el of [this.backdropTarget, this.contentTarget]) {
      if (el.showPopover && !el.matches(":popover-open")) el.showPopover()
    }
  }

  hidePopovers() {
    for (const el of [this.contentTarget, this.backdropTarget]) {
      if (el.hidePopover && el.matches(":popover-open")) el.hidePopover()
    }
  }
}
