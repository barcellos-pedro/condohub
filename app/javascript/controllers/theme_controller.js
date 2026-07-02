import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["icon"]

  connect() {
    const saved = localStorage.getItem("theme")
    const theme = saved === "dark" ? "dark" : "light"
    this.setTheme(theme)
  }

  toggle() {
    const current = document.documentElement.getAttribute("data-theme")
    const next = current === "dark" ? "light" : "dark"
    this.setTheme(next)
    localStorage.setItem("theme", next)
  }

  setTheme(theme) {
    document.documentElement.setAttribute("data-theme", theme)
    if (this.hasIconTarget) {
      this.iconTarget.textContent = theme === "light" ? "🌙" : "☀️"
    }
  }
}
