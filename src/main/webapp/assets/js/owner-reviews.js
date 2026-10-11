document.addEventListener('DOMContentLoaded', () => {
    const body = document.body;
    const sidebarToggle = document.querySelector('[data-sidebar-toggle]');
    const sidebarClose = document.querySelector('[data-sidebar-close]');
    const sidebarOverlay = document.querySelector('[data-sidebar-overlay]');

    function closeSidebar() {
        body.classList.remove('sidebar-open');
        sidebarToggle.setAttribute('aria-expanded', 'false');
    }

    sidebarToggle.addEventListener('click', () => {
        const isOpen = body.classList.toggle('sidebar-open');
        sidebarToggle.setAttribute('aria-expanded', String(isOpen));
    });
    sidebarClose.addEventListener('click', closeSidebar);
    sidebarOverlay.addEventListener('click', closeSidebar);
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

    document.querySelectorAll('.review-reply-form').forEach(form => {
        form.addEventListener('submit', event => {
            const reply = form.querySelector('[name="ownerReply"]');
            reply.setCustomValidity('');
            if (reply.value.trim().length === 0) {
                event.preventDefault();
                reply.setCustomValidity('Nội dung phản hồi không được để trống.');
                reply.reportValidity();
                reply.focus();
                return;
            }
            const submitButton = form.querySelector('[type="submit"]');
            submitButton.disabled = true;
            submitButton.textContent = 'Đang lưu...';
        });
        form.querySelector('[name="ownerReply"]').addEventListener('input', event => {
            event.target.setCustomValidity('');
        });
    });

    // Restore controls when the browser returns to this page from its history cache.
    window.addEventListener('pageshow', () => {
        document.querySelectorAll('.review-reply-form [type="submit"]').forEach(button => {
            button.disabled = false;
            button.textContent = button.closest('details').querySelector('summary').textContent
                .includes('Chỉnh sửa') ? 'Lưu thay đổi' : 'Gửi phản hồi';
        });
    });
});
