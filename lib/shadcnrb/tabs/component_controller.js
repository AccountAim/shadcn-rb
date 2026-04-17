import { Controller } from "@hotwired/stimulus"

// Identifier: shadcnrb--tabs--component
export default class extends Controller {
  static values = { active: String }

  connect() {
    this.updateUI()
  }

  select(event) {
    this.activeValue = event.currentTarget.dataset.tabValue
    this.updateUI()
  }

  updateUI() {
    const active = this.activeValue

    this.element.querySelectorAll("[data-tab-value]").forEach((el) => {
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
