import { Controller } from "@hotwired/stimulus"

// Identifier: shadcnrb--theme-switcher--component
//
// Persists theme + mode in cookies (`shadcnrb_theme`, `shadcnrb_mode`) so
// the server renders them onto <html> via `sui.theme_class`; applies the
// classes here too, so a change shows without a reload. Each pick also
// dispatches `change` with `{ theme, mode }` for the host to store.
const THEME_KEY = "shadcnrb_theme"
const MODE_KEY = "shadcnrb_mode"
const THEMES = ["default", "blue", "green", "rose", "violet", "orange"]
const MAX_AGE = 60 * 60 * 24 * 365

export default class extends Controller {
  static targets = ["panel"]

  connect() {
    this.updateUI()
    this._onClickOutside = (e) => { if (!this.element.contains(e.target)) this.close() }
    document.addEventListener("click", this._onClickOutside)
  }

  disconnect() {
    document.removeEventListener("click", this._onClickOutside)
  }

  toggle() {
    this.panelTarget.dataset.state = this.panelTarget.dataset.state === "open" ? "closed" : "open"
  }

  close() {
    if (this.hasPanelTarget) this.panelTarget.dataset.state = "closed"
  }

  setTheme(event) {
    this.store(THEME_KEY, event.currentTarget.dataset.theme)
    this.changed()
  }

  setMode(event) {
    this.store(MODE_KEY, event.currentTarget.dataset.mode)
    this.changed()
  }

  changed() {
    const theme = this.currentTheme, mode = this.currentMode
    this.apply(theme, mode)
    this.updateUI()
    this.dispatch("change", { detail: { theme, mode } })
  }

  apply(theme, mode) {
    const html = document.documentElement
    THEMES.forEach(t => html.classList.remove(`sui-theme-${t}`))
    if (theme && theme !== "default") html.classList.add(`sui-theme-${theme}`)
    html.classList.toggle("dark", mode === "dark")
  }

  updateUI() {
    this.element.querySelectorAll("[data-theme]").forEach(el => {
      el.dataset.selected = (el.dataset.theme === this.currentTheme).toString()
    })
    this.element.querySelectorAll("[data-mode]").forEach(el => {
      el.dataset.selected = (el.dataset.mode === this.currentMode).toString()
    })
  }

  store(key, value) {
    document.cookie = `${key}=${value};path=/;max-age=${MAX_AGE};samesite=lax`
  }

  read(key) {
    return document.cookie.match(new RegExp(`(?:^|; )${key}=([^;]*)`))?.[1]
  }

  get currentTheme() {
    return this.read(THEME_KEY) || "default"
  }

  get currentMode() {
    return this.read(MODE_KEY) || "light"
  }
}
