import { Controller } from "@hotwired/stimulus"

// Wraps a trigger (usually a button). On click, clones the toaster's
// template for the variant, fills in the text, and appends it — the markup
// has one source, the server (`sui.toaster` must be on the page).
export default class extends Controller {
  static values = {
    title:       String,
    description: String,
    variant:     { type: String, default: "default" },
    duration:    { type: Number, default: 5000 }
  }

  show() {
    const toaster = document.getElementById("shadcnrb-toasts")
    const template = toaster.querySelector(`template[data-variant="${this.variantValue}"]`)
    const toast = template.content.firstElementChild.cloneNode(true)
    toast.setAttribute("data-shadcnrb--toast--component-duration-value", String(this.durationValue))
    toast.querySelector('[data-slot="toast-title"]').textContent = this.titleValue
    const description = toast.querySelector('[data-slot="toast-description"]')
    if (this.descriptionValue) {
      description.textContent = this.descriptionValue
    } else {
      description.remove()
    }
    toaster.appendChild(toast)
  }
}
