import { Controller } from "@hotwired/stimulus"

// Identifier: shadcnrb--theme-switcher--component
//
// Persists theme + mode selection in localStorage and applies matching classes
// to <html>. Pair with an inline init script in <head> to avoid FOUC.
const THEME_KEY = "shadcnrb-theme"
const MODE_KEY = "shadcnrb-mode"
const THEMES = ["default", "blue", "green", "rose", "violet", "orange"]

export default class extends Controller {
  static targets = ["panel"]

  connect() {
    this.apply(this.currentTheme, this.currentMode)
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
    const theme = event.currentTarget.dataset.theme
    localStorage.setItem(THEME_KEY, theme)
    this.apply(theme, this.currentMode)
    this.updateUI()
  }

  setMode(event) {
    const mode = event.currentTarget.dataset.mode
    localStorage.setItem(MODE_KEY, mode)
    this.apply(this.currentTheme, mode)
    this.updateUI()
  }

  apply(theme, mode) {
    const html = document.documentElement
    THEMES.forEach(t => html.classList.remove(`theme-${t}`))
    if (theme && theme !== "default") html.classList.add(`theme-${theme}`)
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

  get currentTheme() {
    return localStorage.getItem(THEME_KEY) || "default"
  }

  get currentMode() {
    return localStorage.getItem(MODE_KEY) || "light"
  }
}
