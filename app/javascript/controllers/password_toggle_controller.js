import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["fields", "label"]

  toggle() {
    const isHidden = this.fieldsTarget.style.display === "none"
    this.fieldsTarget.style.display = isHidden ? "block" : "none"
    this.labelTarget.textContent = isHidden
      ? this.labelTarget.dataset.hideLabel
      : this.labelTarget.dataset.showLabel
  }
}
