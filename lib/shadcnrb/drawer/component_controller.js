import { Controller } from "@hotwired/stimulus"

// Identifier: shadcnrb--drawer--component
export default class extends Controller {
  static targets = ["content", "backdrop"]

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
    this.contentTarget.dataset.state = "open"
    this.backdropTarget.dataset.state = "open"
    document.body.style.overflow = "hidden"
  }

  close() {
    this.contentTarget.dataset.state = "closed"
    this.backdropTarget.dataset.state = "closed"
    setTimeout(() => {
      document.body.style.overflow = ""
    }, 300)
  }
}
