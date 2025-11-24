self.addEventListener("push", async (event) => {
    const data = await event.data.json()
    const title = data.title || "Golden Path"
    const options = {
        body: data.body,
        icon: "/icon.png", // Ensure this file exists in public/
        data: { path: data.path } // We will send a URL path to open
    }

    event.waitUntil(
        self.registration.showNotification(title, options)
    )
})

self.addEventListener("notificationclick", function(event) {
    event.notification.close()

    event.waitUntil(
        clients.matchAll({ type: "window" }).then((clientList) => {
            // If the URL is already open, focus it
            for (let i = 0; i < clientList.length; i++) {
                let client = clientList[i]
                let clientPath = (new URL(client.url)).pathname

                if (clientPath === event.notification.data.path && "focus" in client) {
                    return client.focus()
                }
            }

            // Otherwise open a new window
            if (clients.openWindow) {
                return clients.openWindow(event.notification.data.path || "/")
            }
        })
    )
})