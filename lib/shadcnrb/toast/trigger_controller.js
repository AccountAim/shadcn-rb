import { Controller } from "@hotwired/stimulus"

// Wraps a trigger (usually a button). On click, appends a toast to a
// lazily-created body-level container — no wrapping controller required
// anywhere on the page.
export default class extends Controller {
  static values = {
    title:       String,
    description: String,
    variant:     { type: String, default: "default" },
    duration:    { type: Number, default: 5000 }
  }

  show() {
    const container = this.ensureContainer()
    const toast = document.createElement("div")
    toast.setAttribute("data-controller", "shadcnrb--toast--component")
    toast.setAttribute("data-shadcnrb--toast--component-duration-value", String(this.durationValue))
    const variantClasses = this.variantValue === "destructive"
      ? "bg-destructive text-destructive-foreground border-destructive"
      : "bg-background text-foreground border"
    toast.className =
      `pointer-events-auto relative flex w-full items-center justify-between space-x-2 ` +
      `overflow-hidden rounded-md p-4 shadow-lg transition-all ${variantClasses}`
    const safe = (s) => String(s).replace(/[&<>"']/g, c => (
      { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]
    ))
    toast.innerHTML =
      `<div class="flex-1">` +
      `<p class="text-sm font-semibold">${safe(this.titleValue || "Notification")}</p>` +
      (this.descriptionValue ? `<p class="text-sm opacity-90">${safe(this.descriptionValue)}</p>` : "") +
      `</div>` +
      `<button type="button" aria-label="Close" class="shrink-0 rounded-sm opacity-70 hover:opacity-100 transition-opacity" data-action="click->shadcnrb--toast--component#dismiss">` +
      `<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 6 6 18"/><path d="m6 6 12 12"/></svg>` +
      `</button>`
    container.appendChild(toast)
  }

  ensureContainer() {
    let c = document.getElementById("shadcnrb-toasts")
    if (!c) {
      c = document.createElement("div")
      c.id = "shadcnrb-toasts"
      c.className =
        "fixed bottom-4 right-4 z-[100] flex flex-col gap-2 w-full max-w-sm pointer-events-none"
      document.body.appendChild(c)
    }
    return c
  }
}
