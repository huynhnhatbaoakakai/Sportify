(() => {
    const panel = document.querySelector('[data-owner-availability]');
    if (!panel) return;
    const status = document.querySelector('[data-calendar-status]');
    const form = document.querySelector('[data-block-form]');
    let loading = false;
    async function refresh() {
        if (loading || document.hidden) return;
        loading = true;
        try {
            const day = await SportifyAvailability.load(panel.dataset.context, panel.dataset.fieldId, panel.dataset.date);
            SportifyAvailability.render(panel, day, window => {
                form.elements.startsAt.value = window.startsAt.slice(0, 16);
                form.elements.endsAt.value = window.endsAt.slice(0, 16);
                form.elements.reason.focus();
                form.scrollIntoView({behavior: 'smooth', block: 'center'});
            });
            status.textContent = 'Lịch được làm mới mỗi 15 giây. Bấm khoảng trống để điền giờ khóa.';
            status.classList.remove('error');
        } catch (error) { status.textContent = error.message; status.classList.add('error'); }
        finally { loading = false; }
    }
    if (form) form.addEventListener('submit', event => {
        if (form.elements.endsAt.value <= form.elements.startsAt.value) {
            event.preventDefault(); alert('Giờ kết thúc phải sau giờ bắt đầu.');
        }
    });
    document.querySelectorAll('[data-unblock-form]').forEach(item => item.addEventListener('submit', event => {
        if (!confirm('Mở lại khoảng giờ này để khách có thể đặt sân?')) event.preventDefault();
    }));
    refresh();
    setInterval(refresh, 15000);
})();
