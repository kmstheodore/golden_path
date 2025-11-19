import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    vapidPublicKey: String,
    postUrl: String
  }

  async connect() {
    if (!("serviceWorker" in navigator)) return

    // Register service worker if not already done
    navigator.serviceWorker.register("/service-worker.js")
  }

  async subscribe() {
    if (!("serviceWorker" in navigator)) return

    const registration = await navigator.serviceWorker.ready
    let subscription = await registration.pushManager.getSubscription()

    if (!subscription) {
      subscription = await registration.pushManager.subscribe({
        userVisibleOnly: true,
        applicationServerKey: this.urlBase64ToUint8Array(this.vapidPublicKeyValue)
      })
    }

    this.sendSubscriptionToServer(subscription)
  }

  async sendSubscriptionToServer(subscription) {
    const response = await fetch(this.postUrlValue, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content
      },
      body: JSON.stringify({
        subscription: subscription.toJSON()
      })
    })

    if (response.ok) {
      alert("Device registered successfully!")
    } else {
      alert("Failed to register device.")
    }
  }

  // Helper to convert VAPID key
  urlBase64ToUint8Array(base64String) {
    const padding = "=".repeat((4 - base64String.length % 4) % 4)
    const base64 = (base64String + padding).replace(/\-/g, "+").replace(/_/g, "/")
    const rawData = window.atob(base64)
    const outputArray = new Uint8Array(rawData.length)
    for (let i = 0; i < rawData.length; ++i) {
      outputArray[i] = rawData.charCodeAt(i)
    }
    return outputArray
  }
}
