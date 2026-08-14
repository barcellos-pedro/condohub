import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["trigger", "form"]

  connect() {
    if (this.hasFormTarget && this.formTarget.querySelector(".form-error")) {
      this.expand()
    }
  }

  expand() {
    if (this.hasTriggerTarget) this.triggerTarget.hidden = true
    if (this.hasFormTarget) {
      this.formTarget.hidden = false
      const firstInput = this.formTarget.querySelector("input, textarea")
      if (firstInput) firstInput.focus()
    }
  }

  collapse() {
    if (this.hasFormTarget) this.formTarget.hidden = true
    if (this.hasTriggerTarget) this.triggerTarget.hidden = false
  }
}
