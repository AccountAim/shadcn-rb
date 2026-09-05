import { Controller } from "@hotwired/stimulus"

// Identifier: shadcnrb--tabs--component
export default class extends Controller {
  static values = { active: String }

  connect() {
    this._detachedClick = this.detachedClick.bind(this)
    document.addEventListener("click", this._detachedClick)
    this.updateUI()
  }

  disconnect() {
    document.removeEventListener("click", this._detachedClick)
  }

  select(event) {
    this.activate(event.currentTarget.dataset.tabValue)
  }

  // Detached triggers: any element with data-tabs="<this root's id>" and a
  // data-tab-value selects that tab from anywhere in the document
  // (`sui.tabs_strip tabs: "id", names: [...]`).
  detachedClick(event) {
    if (!this.element.id) return
    const ref = event.target.closest("[data-tabs][data-tab-value]")
    if (!ref || ref.dataset.tabs !== this.element.id || this.element.contains(ref)) return
    event.preventDefault()
    this.activate(ref.dataset.tabValue)
  }

  activate(value) {
    this.activeValue = value
    this.updateUI()
  }

  get parts() {
    const own = Array.from(this.element.querySelectorAll("[data-tab-value]")).filter(
      (part) => part.closest('[data-slot="tabs"]') === this.element,
    )
    if (!this.element.id) return own
    const detached = document.querySelectorAll(`[data-tabs="${CSS.escape(this.element.id)}"][data-tab-value]`)
    return own.concat(Array.from(detached))
  }

  updateUI() {
    const active = this.activeValue
    this.parts.forEach((el) => {
      const isActive = el.dataset.tabValue === active
      const isTrigger = el.tagName === "BUTTON" || el.role === "tab"
      const isContent = el.getAttribute("role") === "tabpanel"

      if (isTrigger) {
        el.dataset.state = isActive ? "active" : "inactive"
        el.setAttribute("aria-selected", isActive ? "true" : "false")
      }

      if (isContent) {
        el.dataset.state = isActive ? "active" : "inactive"
        if (isActive) {
          el.removeAttribute("hidden")
        } else {
          el.setAttribute("hidden", "")
        }
      }
    })
  }
}
