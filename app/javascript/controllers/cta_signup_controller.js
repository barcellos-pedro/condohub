import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["email", "submitBtn", "feedback"]

  submit(event) {
    event.preventDefault()

    const emailValue = this.emailTarget.value
    if (emailValue) {
      this.submitBtnTarget.disabled = true
      this.submitBtnTarget.innerText = "..."

      // Simulate API submit and display modern inline response
      setTimeout(() => {
        event.target.classList.add("hidden")
        this.feedbackTarget.classList.remove("hidden")
      }, 600)
    }
  }
}
