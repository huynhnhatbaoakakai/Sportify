document.addEventListener('DOMContentLoaded', () => {
    const body = document.body;
    const sidebarToggle = document.querySelector('[data-sidebar-toggle]');
    const sidebarClose = document.querySelector('[data-sidebar-close]');
    const sidebarOverlay = document.querySelector('[data-sidebar-overlay]');
    const toast = document.querySelector('[data-toast]');
    let toastTimer;

    function showToast(message) {
        toast.textContent = message;
        toast.classList.add('show');
        window.clearTimeout(toastTimer);
        toastTimer = window.setTimeout(() => toast.classList.remove('show'), 3500);
    }

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
    document.querySelectorAll('.sidebar-nav a[href^="#"]').forEach(link => {
        link.addEventListener('click', closeSidebar);
    });
    window.matchMedia('(min-width: 851px)').addEventListener('change', event => {
        if (event.matches) closeSidebar();
    });

    const currentDate = document.querySelector('[data-current-date]');
    const today = new Date();
    currentDate.textContent = new Intl.DateTimeFormat('vi-VN', {
        weekday: 'long', day: '2-digit', month: '2-digit', year: 'numeric'
    }).format(today);

    const bookingRows = Array.from(document.querySelectorAll('[data-booking-row]'));
    bookingRows.forEach(row => {
        const date = new Date(today.getFullYear(), today.getMonth(), today.getDate() + Number(row.dataset.dateOffset));
        const dateText = new Intl.DateTimeFormat('vi-VN', { day: '2-digit', month: '2-digit' }).format(date);
        const datePrefix = row.dataset.dateOffset === '-1' ? 'Hôm qua' : row.dataset.dateOffset === '1' ? 'Ngày mai' : 'Hôm nay';
        const time = row.querySelector('time');
        time.dateTime = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}T${time.dateTime.slice(11, 16)}`;
        time.closest('td').querySelector('.cell-note').textContent = `${datePrefix}, ${dateText}`;
    });

    const filterButtons = Array.from(document.querySelectorAll('[data-status-filter]'));
    const bookingSearch = document.querySelector('[data-booking-search]');
    const bookingResult = document.querySelector('[data-booking-result]');
    const emptyState = document.querySelector('[data-empty-state]');
    let activeFilter = 'all';

    function normalizeSearch(value) {
        return value.toLocaleLowerCase('vi-VN').normalize('NFD')
            .replace(/[\u0300-\u036f]/g, '').replace(/đ/g, 'd');
    }

    function updatePendingCount() {
        const pending = bookingRows.filter(row => row.dataset.status === 'pending').length;
        document.querySelector('[data-pending-count]').textContent = pending;
        document.querySelector('[data-pending-nav-count]').textContent = pending;
        document.querySelector('[data-pending-message-count]').textContent = `${pending} lịch đặt`;
        return pending;
    }

    function filterBookings() {
        const query = normalizeSearch(bookingSearch.value.trim());
        let visible = 0;
        bookingRows.forEach(row => {
            const matchesStatus = activeFilter === 'all' || row.dataset.status === activeFilter;
            const matchesSearch = normalizeSearch(`${row.dataset.search} ${row.textContent}`).includes(query);
            row.hidden = !(matchesStatus && matchesSearch);
            if (!row.hidden) visible += 1;
        });
        emptyState.hidden = visible !== 0;
        bookingResult.textContent = `Hiển thị ${visible} / ${bookingRows.length} lịch đặt`;
    }

    filterButtons.forEach(button => {
        button.addEventListener('click', () => {
            activeFilter = button.dataset.statusFilter;
            filterButtons.forEach(item => {
                const selected = item === button;
                item.classList.toggle('active', selected);
                item.setAttribute('aria-pressed', String(selected));
            });
            filterBookings();
        });
    });
    bookingSearch.addEventListener('input', filterBookings);

    document.querySelector('[data-booking-body]').addEventListener('click', event => {
        const button = event.target.closest('[data-booking-action]');
        if (!button) return;
        const row = button.closest('[data-booking-row]');
        if (row.dataset.status !== 'pending') return;

        const confirmed = button.dataset.bookingAction === 'confirm';
        row.dataset.status = confirmed ? 'confirmed' : 'rejected';
        const badge = row.querySelector('.status-badge');
        badge.className = `status-badge status-${row.dataset.status}`;
        badge.textContent = confirmed ? 'Đã xác nhận' : 'Đã từ chối';
        const finished = document.createElement('span');
        finished.className = 'action-finished';
        finished.textContent = 'Đã xử lý';
        row.querySelector('.booking-actions').replaceChildren(finished);
        updatePendingCount();
        filterBookings();
        showToast(`${confirmed ? 'Đã xác nhận' : 'Đã từ chối'} đơn ${row.querySelector('.booking-code').textContent}.`);
    });

    document.querySelector('.notification-button').addEventListener('click', () => {
        showToast(`Bạn có ${updatePendingCount()} yêu cầu chờ xác nhận.`);
    });

    const fieldGrid = document.querySelector('[data-fields-grid]');
    const fieldTemplate = document.querySelector('#field-card-template');
    const fieldModal = document.querySelector('[data-field-modal]');
    const fieldForm = document.querySelector('[data-field-form]');
    const fieldTitle = document.querySelector('[data-field-modal-title]');
    const fieldSubmit = document.querySelector('[data-field-submit]');
    const nameInput = fieldForm.querySelector('[name="name"]');
    const sportInput = fieldForm.querySelector('[name="sport"]');
    const addressInput = fieldForm.querySelector('[name="address"]');
    const priceInput = fieldForm.querySelector('[name="price"]');
    const statusInput = fieldForm.querySelector('[name="status"]');
    const priceFormatter = new Intl.NumberFormat('vi-VN');
    let editingCard = null;
    let returnFocus = null;

    function updateActiveFieldCount() {
        document.querySelector('[data-active-field-count]').textContent =
            fieldGrid.querySelectorAll('[data-field-card][data-status="active"]').length;
    }

    function setFieldStatus(card, status) {
        const active = status === 'active';
        card.dataset.status = active ? 'active' : 'paused';
        const badge = card.querySelector('[data-field-status]');
        badge.className = `field-status status-${card.dataset.status}`;
        badge.textContent = active ? 'Đang hoạt động' : 'Tạm ngưng';
        card.querySelector('[data-field-toggle]').textContent = active ? 'Tạm ngưng' : 'Khôi phục';
        updateActiveFieldCount();
    }

    function writeFieldCard(card, values) {
        card.querySelector('[data-field-name]').textContent = values.name;
        card.querySelector('[data-field-sport]').textContent = values.sport;
        card.querySelector('[data-field-address]').textContent = values.address;
        card.querySelector('[data-field-price]').textContent = `${priceFormatter.format(values.price)}đ`;
        card.dataset.price = String(values.price);
        setFieldStatus(card, values.status);
    }

    function openFieldModal(card) {
        editingCard = card;
        returnFocus = document.activeElement;
        fieldForm.reset();
        fieldTitle.textContent = card ? 'Chỉnh sửa sân' : 'Thêm sân';
        fieldSubmit.textContent = card ? 'Lưu thay đổi' : 'Thêm sân';
        if (card) {
            nameInput.value = card.querySelector('[data-field-name]').textContent;
            sportInput.value = card.querySelector('[data-field-sport]').textContent;
            addressInput.value = card.querySelector('[data-field-address]').textContent;
            priceInput.value = card.dataset.price;
            statusInput.value = card.dataset.status;
        }
        fieldModal.hidden = false;
        body.classList.add('modal-open');
        nameInput.focus();
    }

    function closeFieldModal() {
        fieldModal.hidden = true;
        body.classList.remove('modal-open');
        editingCard = null;
        if (returnFocus && returnFocus.isConnected) returnFocus.focus();
    }

    document.querySelector('[data-field-add]').addEventListener('click', () => openFieldModal(null));
    document.querySelectorAll('[data-field-modal-close]').forEach(button => {
        button.addEventListener('click', closeFieldModal);
    });
    fieldModal.addEventListener('click', event => {
        if (event.target === fieldModal) closeFieldModal();
    });

    fieldGrid.addEventListener('click', event => {
        const card = event.target.closest('[data-field-card]');
        if (!card) return;
        if (event.target.closest('[data-field-edit]')) {
            openFieldModal(card);
        } else if (event.target.closest('[data-field-toggle]')) {
            const nextStatus = card.dataset.status === 'active' ? 'paused' : 'active';
            setFieldStatus(card, nextStatus);
            showToast(`${card.querySelector('[data-field-name]').textContent}: ${nextStatus === 'active' ? 'đã khôi phục' : 'đã tạm ngưng'}.`);
        }
    });

    fieldForm.addEventListener('submit', event => {
        event.preventDefault();
        if (!fieldForm.reportValidity()) return;
        const values = {
            name: nameInput.value.trim(),
            sport: sportInput.value,
            address: addressInput.value.trim(),
            price: Number(priceInput.value),
            status: statusInput.value
        };
        if (!values.name || !values.address || !Number.isFinite(values.price) || values.price < 0) return;

        const isEditing = Boolean(editingCard);
        const card = editingCard || fieldTemplate.content.firstElementChild.cloneNode(true);
        if (!isEditing) fieldGrid.appendChild(card);
        writeFieldCard(card, values);
        closeFieldModal();
        showToast(`${isEditing ? 'Đã cập nhật' : 'Đã thêm'} sân ${values.name}.`);
    });

    document.addEventListener('keydown', event => {
        if (event.key === 'Escape') {
            if (!fieldModal.hidden) closeFieldModal();
            else if (body.classList.contains('sidebar-open')) closeSidebar();
        }
        if (event.key === 'Tab' && !fieldModal.hidden) {
            const focusable = Array.from(fieldModal.querySelectorAll('button, input, select'));
            const first = focusable[0];
            const last = focusable[focusable.length - 1];
            if (event.shiftKey && document.activeElement === first) {
                event.preventDefault();
                last.focus();
            } else if (!event.shiftKey && document.activeElement === last) {
                event.preventDefault();
                first.focus();
            }
        }
    });

    updatePendingCount();
    updateActiveFieldCount();
    filterBookings();
});
