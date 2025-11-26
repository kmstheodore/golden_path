import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["device", "button", "status"]

    connect() {
        // CHANGED: Removed the logic that disabled buttons on load.
        // We always want to allow the user to click "Subscribe" to sync
        // with the backend, even if the browser already has permission.
        if (Notification.permission === "granted") {
            this.statusTarget.textContent = "✅ Browser permission granted. Click below to save."
        }
    }

    async subscribe(event) {
        event.preventDefault()

        if (!this.deviceTarget.value) {
            alert("Please name this device (e.g., 'Work Laptop')")
            return
        }

        this.buttonTarget.disabled = true
        this.statusTarget.textContent = "⏳ Subscribing..."

        // 1. Request Permission (resolves instantly if already granted)
        const permission = await Notification.requestPermission()
        if (permission !== "granted") {
            alert("Permission denied")
            this.buttonTarget.disabled = false
            this.statusTarget.textContent = "❌ Permission denied"
            return
        }

        // 2. Subscribe to PushManager
        const vapidPublicKey = document.head.querySelector("meta[name='vapid-public-key']").content
        const convertedKey = this.urlBase64ToUint8Array(vapidPublicKey)

        const registration = await navigator.serviceWorker.ready

        const subscription = await registration.pushManager.subscribe({
            userVisibleOnly: true,
            applicationServerKey: convertedKey
        })

        // 3. Send to Backend
        const response = await fetch("/web_push_subscriptions", {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
            },
            body: JSON.stringify({
                subscription: subscription.toJSON(),
                device_name: this.deviceTarget.value
            })
        })

        if (response.ok) {
            this.statusTarget.textContent = "✅ Success! Redirecting..."
            // CHANGED: Automatically send them to the dashboard
            window.location.href = "/"
        } else {
            alert("Failed to save subscription on server.")
            this.buttonTarget.disabled = false
            this.statusTarget.textContent = "❌ Server Error. Try again."
        }
    }

    // (Helper remains unchanged)
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