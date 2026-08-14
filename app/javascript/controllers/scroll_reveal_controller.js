import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          entry.target.classList.add("revealed")
          observer.unobserve(entry.target)
        }
      })
    }, { threshold: 0.15 })
    
    observer.observe(this.element)
  }
}
