import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select"]

  change() {
    const locale = this.selectTarget.value
    const path = window.location.pathname
    const search = window.location.search

    const match = path.match(/^\/(en|pt\-BR|es|ko)(\/|$)/)

    let newPath
    if (match) {
      newPath = "/" + locale + match[2] + path.slice(match[0].length)
    } else {
      newPath = "/" + locale + path
    }

    window.location.href = newPath + search
  }
}
