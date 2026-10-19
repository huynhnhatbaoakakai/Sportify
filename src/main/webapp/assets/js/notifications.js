(() => {
    if (window.sportifyNotificationsStarted) return;
    window.sportifyNotificationsStarted = true;
    const script = document.querySelector('[data-notifications-poller]');
    if (!script) return;
    let running = false;
    const update = async () => {
        if (running || document.hidden) return;
        running = true;
        try {
            const response = await fetch(script.dataset.context + '/notifications-api', {cache: 'no-store'});
            if (response.status === 401 || response.redirected) { clearInterval(timer); return; }
            if (!response.ok) return;
            const data = await response.json();
            document.querySelectorAll('[data-notification-count]').forEach(badge => {
                badge.textContent = String(data.unreadCount);
                badge.classList.toggle('has-unread', data.unreadCount > 0);
            });
        } catch (_) { /* Retry at the next poll; server-rendered links remain usable. */ }
        finally { running = false; }
    };
    const timer = setInterval(update, 15000);
    update();
    document.addEventListener('visibilitychange', () => { if (!document.hidden) update(); });
})();
