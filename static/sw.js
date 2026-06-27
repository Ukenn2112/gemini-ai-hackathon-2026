const CACHE_NAME = "slipscout-cache-v1";
const ASSETS_TO_CACHE = [
  "/",
  "/static/style.css",
  "/static/icon-192.png",
  "/static/icon-512.png",
  "https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&family=Outfit:wght@500;600;800&display=swap",
  "https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap",
  "https://cdn.tailwindcss.com?plugins=forms,container-queries"
];

// Install Event - Pre-cache core shell
self.addEventListener("install", event => {
  event.waitUntil(
    caches.open(CACHE_NAME).then(cache => {
      console.log("[Service Worker] Caching app shell and core assets");
      // Use helper to ignore network errors on install if offline during start
      return Promise.allSettled(
        ASSETS_TO_CACHE.map(url => {
          return cache.add(url).catch(err => {
            console.warn(`[Service Worker] Failed to pre-cache asset: ${url}`, err);
          });
        })
      );
    }).then(() => self.skipWaiting())
  );
});

// Activate Event - Clean up stale caches
self.addEventListener("activate", event => {
  event.waitUntil(
    caches.keys().then(keys => {
      return Promise.all(
        keys.map(key => {
          if (key !== CACHE_NAME) {
            console.log("[Service Worker] Purging old cache:", key);
            return caches.delete(key);
          }
        })
      );
    }).then(() => self.clients.claim())
  );
});

// Fetch Event - Stale-While-Revalidate for static resources, Network-Only for APIs
self.addEventListener("fetch", event => {
  const requestUrl = new URL(event.request.url);

  // Handle API Requests - Force Network-Only (No-Cache)
  if (requestUrl.pathname.startsWith("/api/")) {
    event.respondWith(
      fetch(event.request).catch(() => {
        return new Response(JSON.stringify({ error: "Offline: Network unavailable." }), {
          headers: { "Content-Type": "application/json" }
        });
      })
    );
    return;
  }

  // Handle Static Shell Assets - Stale-While-Revalidate
  event.respondWith(
    caches.match(event.request).then(cachedResponse => {
      if (cachedResponse) {
        // Fetch fresh copy in the background to update cache
        fetch(event.request).then(networkResponse => {
          if (networkResponse.status === 200 && event.request.method === "GET") {
            caches.open(CACHE_NAME).then(cache => cache.put(event.request, networkResponse));
          }
        }).catch(() => {/* Ignore background sync failures when offline */});
        
        return cachedResponse;
      }

      return fetch(event.request).then(networkResponse => {
        // Cache newly discovered static GET assets on-the-fly
        if (networkResponse.status === 200 && event.request.method === "GET") {
          const responseToCache = networkResponse.clone();
          caches.open(CACHE_NAME).then(cache => cache.put(event.request, responseToCache));
        }
        return networkResponse;
      });
    })
  );
});
