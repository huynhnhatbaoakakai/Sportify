document.addEventListener('DOMContentLoaded', () => {
    const toggle = document.querySelector('[data-sidebar-toggle]');
    const close = document.querySelector('[data-sidebar-close]');
    const overlay = document.querySelector('[data-sidebar-overlay]');

    function closeSidebar() {
        document.body.classList.remove('sidebar-open');
        toggle.setAttribute('aria-expanded', 'false');
    }

    toggle.addEventListener('click', () => {
        const isOpen = document.body.classList.toggle('sidebar-open');
        toggle.setAttribute('aria-expanded', String(isOpen));
    });
    close.addEventListener('click', closeSidebar);
    overlay.addEventListener('click', closeSidebar);
    document.addEventListener('keydown', event => {
        if (event.key === 'Escape') closeSidebar();
    });
    window.matchMedia('(min-width: 851px)').addEventListener('change', event => {
        if (event.matches) closeSidebar();
    });
    document.querySelector('[data-current-date]').textContent =
        new Intl.DateTimeFormat('vi-VN', {
            weekday: 'long', day: '2-digit', month: '2-digit', year: 'numeric'
        }).format(new Date());
});
