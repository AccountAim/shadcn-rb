import { Controller } from "@hotwired/stimulus"

// Identifier: shadcnrb--anchored--component
//
// Shared engine for anchored overlays (tooltip, hover_card): hover/focus
// open with delays, Esc dismiss, and panel positioning. The panel is a
// `popover="manual"` element — `showPopover()` renders it in the top layer,
// so no ancestor `overflow` or stacking context can clip it. In browsers
// without the Popover API it degrades to a plain `position: fixed` panel.
//
// The panel is placed against the root's rect (the root hugs the trigger)
// on open and on every scroll or resize while open, flipping to the
// opposite side when the declared one doesn't fit and clamping to the
// viewport.

const OFFSET = 4 // trigger-to-panel gap
const PAD = 4    // minimum distance from viewport edges
const OPPOSITE = { top: "bottom", bottom: "top", left: "right", right: "left" }
const clamp = (v, lo, hi) => Math.min(Math.max(v, lo), Math.max(lo, hi))
let uid = 0

export default class extends Controller {
  static targets = ["content"]
  static values = {
    delay: { type: Number, default: 0 },
    closeDelay: { type: Number, default: 0 },
    open: { type: Boolean, default: false },
    describe: { type: Boolean, default: false }
  }

  connect() {
    this.timer = null
    this.reposition = this.reposition.bind(this)
    if (this.describeValue) this.describe()
    this.sync()
  }

  // Also runs on turbo:before-cache, so snapshots are cached closed.
  disconnect() {
    this.dismiss()
    this.sync()
    this.untrack()
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
    open ? this.track() : this.untrack()
  }

  apply(panel, open) {
    panel.dataset.state = open ? "open" : "closed"
    if (panel.showPopover) {
      const shown = panel.matches(":popover-open")
      if (open && !shown) panel.showPopover()
      if (!open && shown) panel.hidePopover()
    }
    if (open) this.place(panel)
  }

  // Subclasses override to anchor a panel to something other than the root
  // (e.g. navigation_menu anchors each panel to its matching trigger).
  anchorFor(panel) {
    return this.element
  }

  // The capture-phase window listener sees scrolls of any inner scroll
  // container too — scroll events don't bubble, but they do capture.
  track() {
    if (this.tracking) return
    this.tracking = true
    addEventListener("scroll", this.reposition, { capture: true, passive: true })
    addEventListener("resize", this.reposition, { passive: true })
  }

  untrack() {
    if (!this.tracking) return
    this.tracking = false
    removeEventListener("scroll", this.reposition, { capture: true })
    removeEventListener("resize", this.reposition)
  }

  reposition() {
    this.contentTargets.forEach(panel => {
      if (panel.dataset.state !== "open") return
      const anchor = this.anchorFor(panel).getBoundingClientRect()
      // Anchor scrolled out of the viewport — closing beats floating detached.
      if (anchor.bottom < 0 || anchor.top > innerHeight ||
          anchor.right < 0 || anchor.left > innerWidth) return this.dismiss()
      this.place(panel)
    })
  }

  place(panel) {
    const anchor = this.anchorFor(panel).getBoundingClientRect()
    const w = panel.offsetWidth
    const h = panel.offsetHeight
    // Flip is recomputed from the declared side each pass, so scrolling back
    // to room flips back.
    const declared = panel.dataset.sideDeclared ??= panel.dataset.side
    const align = panel.dataset.align || "center"
    const side = this.fits(declared, anchor, w, h) ||
      !this.fits(OPPOSITE[declared], anchor, w, h) ? declared : OPPOSITE[declared]

    let x, y
    if (side === "top" || side === "bottom") {
      y = side === "top" ? anchor.top - h - OFFSET : anchor.bottom + OFFSET
      x = align === "start" ? anchor.left
        : align === "end" ? anchor.right - w
        : anchor.left + anchor.width / 2 - w / 2
      x = clamp(x, PAD, innerWidth - w - PAD)
    } else {
      x = side === "left" ? anchor.left - w - OFFSET : anchor.right + OFFSET
      y = align === "start" ? anchor.top
        : align === "end" ? anchor.bottom - h
        : anchor.top + anchor.height / 2 - h / 2
      y = clamp(y, PAD, innerHeight - h - PAD)
    }

    // `margin: 0` overrides the UA's `[popover] { margin: auto; inset: 0 }`.
    Object.assign(panel.style, {
      position: "fixed", margin: "0",
      top: `${y}px`, left: `${x}px`, right: "auto", bottom: "auto"
    })
    panel.dataset.side = side
    this.placeArrow(panel, side, anchor, x, y, w, h)
  }

  fits(side, anchor, w, h) {
    const space = {
      top: anchor.top, bottom: innerHeight - anchor.bottom,
      left: anchor.left, right: innerWidth - anchor.right
    }[side]
    const need = side === "top" || side === "bottom" ? h : w
    return space >= need + OFFSET + PAD
  }

  // Half-embeds the arrow in the panel edge facing the trigger, centred on
  // the trigger even when the panel was shifted, clamped off the corners.
  placeArrow(panel, side, anchor, x, y, w, h) {
    const arrow = panel.querySelector('[data-slot$="-arrow"]')
    if (!arrow) return
    const size = arrow.offsetWidth
    const style = { top: "auto", bottom: "auto", left: "auto", right: "auto" }
    if (side === "top" || side === "bottom") {
      style[side === "top" ? "bottom" : "top"] = `${-size / 2}px`
      style.left = `${clamp(anchor.left + anchor.width / 2 - x - size / 2, size / 2, w - size * 1.5)}px`
    } else {
      style[side === "left" ? "right" : "left"] = `${-size / 2}px`
      style.top = `${clamp(anchor.top + anchor.height / 2 - y - size / 2, size / 2, h - size * 1.5)}px`
    }
    Object.assign(arrow.style, style)
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
