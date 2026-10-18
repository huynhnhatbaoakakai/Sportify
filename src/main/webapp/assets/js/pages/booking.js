(() => {
    const form = document.querySelector('[data-booking-form]');
    if (!form) return;
    const date = form.elements.date;
    const start = form.elements.startTime;
    const end = form.elements.endTime;
    const submit = form.querySelector('[type="submit"]');
    const submitLabel = form.querySelector('[data-submit-label]');
    const status = form.querySelector('[data-availability-status]');
    const panel = form.querySelector('[data-booking-availability]');
    const reload = form.querySelector('[data-reload-availability]');
    const selectionError = form.querySelector('[data-selection-error]');
    const durationButtons = [...form.querySelectorAll('[data-duration]')];
    const dateButtons = [...form.querySelectorAll('[data-quick-date]')];
    let day = null, controller = null, loading = false, submitting = false, preferredDuration = 60;
    let renderedWindows = '';

    function minutes(value) {
        if (!/^\d{2}:\d{2}$/.test(value || '')) return NaN;
        return Number(value.slice(0, 2)) * 60 + Number(value.slice(3, 5));
    }
    function clock(value) {
        return String(Math.floor(value / 60)).padStart(2, '0') + ':' + String(value % 60).padStart(2, '0');
    }
    function dateAfter(offset) {
        const result = new Date(form.dataset.today + 'T12:00:00');
        result.setDate(result.getDate() + offset);
        return result.getFullYear() + '-' + String(result.getMonth() + 1).padStart(2, '0') + '-'
            + String(result.getDate()).padStart(2, '0');
    }
    function freeFromStart() {
        if (!day || !day.active || day.date !== date.value || !start.value) return null;
        const value = date.value + 'T' + start.value;
        return day.windows.find(slot => slot.status === 'FREE'
            && value >= slot.startsAt.slice(0, 16) && value < slot.endsAt.slice(0, 16));
    }
    function selectedSlot() {
        const slot = freeFromStart();
        return slot && end.value && minutes(end.value) > minutes(start.value)
            && date.value + 'T' + end.value <= slot.endsAt.slice(0, 16) ? slot : null;
    }
    function message(text, isError = false) {
        if (status.textContent !== text) status.textContent = text;
        status.classList.toggle('error', isError);
    }
    function updateSelection() {
        const slot = selectedSlot();
        const valid = Boolean(slot);
        const duration = minutes(end.value) - minutes(start.value);
        const canStart = freeFromStart();
        submit.disabled = loading || submitting || !valid;
        if (!submitting) submitLabel.textContent = day && day.autoApprove ? 'Xác nhận đặt sân' : 'Gửi yêu cầu đặt sân';
        dateButtons.forEach(button => {
            const active = date.value === dateAfter(Number(button.dataset.quickDate));
            button.classList.toggle('is-active', active);
            button.setAttribute('aria-pressed', String(active));
        });
        durationButtons.forEach(button => {
            const value = Number(button.dataset.duration);
            const fits = canStart && minutes(start.value) + value <= minutes(canStart.endsAt.slice(11, 16));
            button.disabled = loading || !fits;
            const active = valid && duration === value;
            button.classList.toggle('is-active', active);
            button.setAttribute('aria-pressed', String(active));
        });
        [...panel.children].forEach((element, index) => {
            if (element.tagName !== 'BUTTON' || !day) return;
            const active = valid && day.windows[index] === slot;
            element.classList.toggle('is-selected', active);
            element.setAttribute('aria-pressed', String(active));
        });
        const invalid = Boolean(day && day.active && start.value && end.value && !valid && !loading);
        start.setAttribute('aria-invalid', String(invalid));
        end.setAttribute('aria-invalid', String(invalid));
        selectionError.hidden = !invalid;
        if (invalid) selectionError.textContent = 'Khoảng giờ này không còn trống hoặc chưa hợp lệ. Hãy chọn một khoảng màu xanh và điều chỉnh giờ chơi.';
        document.querySelector('[data-summary-date]').textContent = date.value
            ? new Date(date.value + 'T12:00:00').toLocaleDateString('vi-VN', {weekday: 'short', day: '2-digit', month: '2-digit', year: 'numeric'})
            : 'Chưa chọn ngày';
        document.querySelector('[data-summary-time]').textContent = valid ? start.value + ' – ' + end.value : 'Chọn giờ còn trống ở trên';
        document.getElementById('calcDurationText').textContent = valid
            ? (duration >= 60 ? Math.floor(duration / 60) + ' giờ' : '') + (duration % 60 ? ' ' + duration % 60 + ' phút' : '')
            : 'Chưa chọn thời lượng';
        document.getElementById('calcPriceText').textContent = valid
            ? Math.round(duration * Number(form.dataset.price) / 60).toLocaleString('vi-VN') + ' ₫' : '—';
    }
    function chooseSlot(slot) {
        const earliest = minutes(slot.startsAt.slice(11, 16));
        const latest = minutes(slot.endsAt.slice(11, 16));
        let begins = Math.ceil(earliest / 15) * 15;
        if (begins >= latest) begins = earliest;
        start.value = clock(begins);
        end.value = clock(Math.min(begins + preferredDuration, latest));
        updateSelection();
    }
    function updateMode() {
        document.querySelector('[data-approval-mode]').textContent = day.autoApprove ? 'Tự động' : 'Chủ sân duyệt';
        form.querySelector('[data-confirmation-note]').textContent = day.autoApprove
            ? 'Đơn hợp lệ sẽ được xác nhận và giữ chỗ ngay sau khi gửi.'
            : 'Yêu cầu được gửi đến chủ sân. Khung giờ chỉ được giữ sau khi chủ sân xác nhận.';
    }
    async function refresh(options = {}) {
        if (submitting) return;
        if (controller) controller.abort();
        if (!date.value) {
            day = null; renderedWindows = ''; panel.replaceChildren(); updateSelection();
            message('Vui lòng chọn ngày đặt sân.'); return;
        }
        const requestController = new AbortController();
        controller = requestController;
        loading = true; submit.disabled = true; reload.disabled = true;
        panel.setAttribute('aria-busy', 'true');
        if (!options.quiet) message('Đang tìm giờ còn trống...');
        try {
            const loaded = await SportifyAvailability.load(form.dataset.context, form.dataset.fieldId, date.value, requestController.signal);
            if (controller !== requestController) return;
            day = loaded;
            const windowsKey = JSON.stringify([day.date, day.windows]);
            if (windowsKey !== renderedWindows) {
                SportifyAvailability.render(panel, day, chooseSlot);
                renderedWindows = windowsKey;
            }
            const firstFree = day.windows.find(slot => slot.status === 'FREE');
            if (options.selectFirst) {
                start.value = ''; end.value = '';
                if (day.active && firstFree) chooseSlot(firstFree);
            }
            updateMode();
            message(!day.active ? 'Sân đang tạm ngưng nhận đặt lịch.'
                : !firstFree ? 'Ngày này đã hết giờ trống. Bạn thử chọn ngày khác nhé.'
                : 'Chọn một khoảng còn trống. Bạn có thể đổi thời lượng và giờ bên dưới.');
        } catch (error) {
            if (error.name === 'AbortError') return;
            if (controller !== requestController) return;
            day = null; renderedWindows = ''; panel.replaceChildren();
            message(error.message + ' Bấm Làm mới để thử lại.', true);
        } finally {
            if (controller === requestController) {
                loading = false; reload.disabled = false; panel.setAttribute('aria-busy', 'false'); updateSelection();
            }
        }
    }

    start.addEventListener('input', updateSelection);
    end.addEventListener('input', updateSelection);
    date.addEventListener('change', () => refresh({selectFirst: true}));
    reload.addEventListener('click', () => refresh({selectFirst: !start.value}));
    dateButtons.forEach(button => button.addEventListener('click', () => {
        date.value = dateAfter(Number(button.dataset.quickDate));
        refresh({selectFirst: true});
    }));
    durationButtons.forEach(button => button.addEventListener('click', () => {
        const duration = Number(button.dataset.duration);
        if (!freeFromStart() || button.disabled) return;
        preferredDuration = duration;
        end.value = clock(minutes(start.value) + duration);
        updateSelection();
    }));
    form.addEventListener('submit', event => {
        if (submitting || loading || !selectedSlot()) {
            event.preventDefault();
            if (!submitting) {
                message('Hãy kiểm tra ngày và chọn lại giờ còn trống trước khi gửi.', true);
                status.scrollIntoView({behavior: 'smooth', block: 'center'});
            }
            return;
        }
        submitting = true; submit.disabled = true; submitLabel.textContent = 'Đang gửi yêu cầu...';
    });
    document.querySelectorAll('[data-fallback-image]').forEach(image => {
        const fallback = () => { if (!image.src.endsWith(image.dataset.fallbackImage)) image.src = image.dataset.fallbackImage; };
        image.addEventListener('error', fallback, {once: true});
        if (image.complete && !image.naturalWidth) fallback();
    });
    updateSelection();
    refresh({selectFirst: true});
    setInterval(() => { if (!document.hidden && !loading && !submitting) refresh({quiet: true}); }, 15000);
    window.addEventListener('pageshow', event => {
        if (event.persisted) { submitting = false; refresh({quiet: true}); }
    });
})();
