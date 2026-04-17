import { Controller } from "@hotwired/stimulus"

// Identifier: shadcnrb--switch--component
export default class extends Controller {
  static targets = ["input"]

  toggle() {
    const isChecked = this.element.dataset.state === "checked"
    const newState = isChecked ? "unchecked" : "checked"

    // Update root button
    this.element.dataset.state = newState
    this.element.setAttribute("aria-checked", String(!isChecked))

    // Update thumb span
    const thumb = this.element.querySelector("span[data-state]")
    if (thumb) thumb.dataset.state = newState

    // Update hidden value input: give it a name only when checked
    if (this.hasInputTarget) {
      if (!isChecked) {
        // Now checked — restore the name so it submits
        this.inputTarget.name = this.inputTarget.dataset.switchName
      } else {
        // Now unchecked — remove name so only the unchecked_value hidden submits
        this.inputTarget.name = ""
      }
    }
  }
}
