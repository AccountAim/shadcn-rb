import { Controller } from "@hotwired/stimulus"
import { computePosition, offset, flip, shift, arrow, hide, autoUpdate } from "@floating-ui/dom"

// Identifier: shadcnrb--anchored--component
//
// Shared engine for anchored overlays (tooltip, hover_card, dropdown_menu,
// navigation_menu): hover/focus open with delays, Esc dismiss, and panel
// positioning. The panel is a `popover="manual"` element — `showPopover()`
// renders it in the top layer, so no ancestor `overflow` or stacking
// context can clip it. In browsers without the Popover API it degrades to
// a plain `position: fixed` panel.
//
// Placement is @floating-ui/dom (pinned into the importmap by the anchored
// install step): offset from the anchor, flip when the declared side
// doesn't fit, shift along the free axis to stay in the viewport, and
// `autoUpdate` re-placement on scroll and resize while open.

const OFFSET = 4 // trigger-to-panel gap
const PAD = 4    // minimum distance from viewport edges
const OPPOSITE = { top: "bottom", bottom: "top", left: "right", right: "left" }
let uid = 0

export default class extends Controller {
  static targets = ["content"]
  static values = {
    delay: { type: Number, default: 0 },
    closeDelay: { type: Number, default: 0 },
    open: { type: Boolean, default: false },
    describe: { type: Boolean, default: false }
  }

  // initialize, not connect: value-changed callbacks fire during binding,
  // before connect, and sync() needs the map.
  initialize() {
    this.timer = null
    this.autoUpdates = new Map()
  }

  connect() {
    if (this.describeValue) this.describe()
    this.sync()
  }

  // Also runs on turbo:before-cache, so snapshots are cached closed.
  disconnect() {
    this.dismiss()
    this.sync()
    this.autoUpdates.forEach(stop => stop())
    this.autoUpdates.clear()
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
    const open = this.openValue
    this.element.dataset.state = open ? "open" : "closed"
    this.contentTargets.forEach(panel => this.apply(panel, open))
  }

  apply(panel, open) {
    panel.dataset.state = open ? "open" : "closed"
    if (panel.showPopover) {
      const shown = panel.matches(":popover-open")
      if (open && !shown) panel.showPopover()
      if (!open && shown) panel.hidePopover()
    }
    open ? this.lazyLoad(panel) : this.resetLazy(panel)
    open ? this.observe(panel) : this.unobserve(panel)
  }

  // Lazy panels (`src:`): fetch the Turbo Frame on first open. autoUpdate's
  // ResizeObserver re-places the panel when the content arrives.
  lazyLoad(panel) {
    const frame = panel.querySelector("turbo-frame[data-lazy-src]")
    if (frame && !frame.getAttribute("src")) frame.setAttribute("src", frame.dataset.lazySrc)
  }

  // `reload:` frames re-fetch on every open: clearing src on close makes
  // the next open call lazyLoad again; the stashed loading state covers
  // the gap.
  resetLazy(panel) {
    const frame = panel.querySelector("turbo-frame[data-lazy-reload]")
    if (!frame || !frame.getAttribute("src")) return
    frame.removeAttribute("src")
    if (frame.dataset.loadingHtml) frame.innerHTML = frame.dataset.loadingHtml
  }

  // Subclasses override to anchor a panel to something other than the root
  // (e.g. navigation_menu anchors each panel to its matching trigger).
  anchorFor(panel) {
    return this.element
  }

  // autoUpdate re-places on ancestor scrolls, window resize, and
  // anchor/panel size changes, and runs once immediately.
  observe(panel) {
    if (this.autoUpdates.has(panel)) return
    this.autoUpdates.set(panel,
      autoUpdate(this.anchorFor(panel), panel, () => this.place(panel)))
  }

  unobserve(panel) {
    this.autoUpdates.get(panel)?.()
    this.autoUpdates.delete(panel)
  }

  place(panel) {
    // Flip is recomputed from the declared side each pass, so scrolling back
    // to room flips back.
    const declared = panel.dataset.sideDeclared ??= panel.dataset.side
    const align = panel.dataset.align || "center"
    const arrowEl = panel.querySelector('[data-slot$="-arrow"]')

    computePosition(this.anchorFor(panel), panel, {
      strategy: "fixed",
      placement: align === "center" ? declared : `${declared}-${align}`,
      middleware: [
        offset(OFFSET),
        flip({ padding: PAD }),
        shift({ padding: PAD }),
        arrowEl && arrow({ element: arrowEl, padding: PAD }),
        hide()
      ].filter(Boolean)
    }).then(({ x, y, placement, middlewareData }) => {
      // Anchor scrolled or clipped out of view — closing beats floating
      // detached.
      if (middlewareData.hide?.referenceHidden) return this.dismiss()

      // `margin: 0` overrides the UA's `[popover] { margin: auto; inset: 0 }`.
      Object.assign(panel.style, {
        position: "fixed", margin: "0",
        top: `${y}px`, left: `${x}px`, right: "auto", bottom: "auto"
      })
      const side = placement.split("-")[0]
      panel.dataset.side = side
      if (arrowEl) this.placeArrow(arrowEl, side, middlewareData.arrow)
    })
  }

  // Half-embeds the arrow in the panel edge facing the anchor, at the
  // anchor-centred coordinate the arrow middleware computed.
  placeArrow(arrowEl, side, { x, y } = {}) {
    const size = arrowEl.offsetWidth
    Object.assign(arrowEl.style, {
      top: y != null ? `${y}px` : "auto",
      left: x != null ? `${x}px` : "auto",
      right: "auto", bottom: "auto",
      [OPPOSITE[side]]: `${-size / 2}px`
    })
  }

  // Wiring aria-describedby server-side would mean threading a unique id
  // through every call site; the pair is always in one controller, so mint it
  // here instead. The trigger is the hoisted markup's first element, or
  // whatever you tag `data-slot="*-trigger"` yourself.
  describe() {
    const panel = this.contentTargets[0]
    const trigger = this.element.querySelector('[data-slot$="-trigger"]') ||
      Array.from(this.element.children).find(c => !this.contentTargets.includes(c))
    if (!trigger || !panel) return
    if (!panel.id) panel.id = `shadcnrb-anchored-${++uid}`
    trigger.setAttribute("aria-describedby", panel.id)
  }
}
