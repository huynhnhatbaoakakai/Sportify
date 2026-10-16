document.addEventListener('DOMContentLoaded', () => {
    // -------------------------------------------------------------------------
    // 1. Điều hướng Sidebar & Ngày hiện tại
    // -------------------------------------------------------------------------
    const toggle = document.querySelector('[data-sidebar-toggle]');
    const close = document.querySelector('[data-sidebar-close]');
    const overlay = document.querySelector('[data-sidebar-overlay]');

    function closeSidebar() {
        document.body.classList.remove('sidebar-open');
        if (toggle) toggle.setAttribute('aria-expanded', 'false');
    }

    if (toggle) {
        toggle.addEventListener('click', () => {
            const isOpen = document.body.classList.toggle('sidebar-open');
            toggle.setAttribute('aria-expanded', String(isOpen));
        });
    }
    if (close) close.addEventListener('click', closeSidebar);
    if (overlay) overlay.addEventListener('click', closeSidebar);

    const dateEl = document.querySelector('[data-current-date]');
    if (dateEl) {
        dateEl.textContent = new Intl.DateTimeFormat('vi-VN', {
            weekday: 'long', day: '2-digit', month: '2-digit', year: 'numeric'
        }).format(new Date());
    }

    // -------------------------------------------------------------------------
    // 2. Toast thông báo sao chép
    // -------------------------------------------------------------------------
    const toast = document.getElementById('copyToast');
    const toastMsg = document.getElementById('copyToastMsg');
    let toastTimer = null;

    function showToast(message) {
        if (!toast) return;
        if (toastMsg) toastMsg.textContent = message;
        toast.classList.add('is-show');
        clearTimeout(toastTimer);
        toastTimer = setTimeout(() => {
            toast.classList.remove('is-show');
        }, 2200);
    }

    // Nút copy số điện thoại trong bảng
    document.querySelectorAll('[data-copy-phone]').forEach(btn => {
        btn.addEventListener('click', (e) => {
            e.stopPropagation();
            const phone = btn.getAttribute('data-copy-phone');
            if (phone && navigator.clipboard) {
                navigator.clipboard.writeText(phone).then(() => {
                    showToast('Đã sao chép SĐT: ' + phone);
                }).catch(() => {
                    showToast('Số điện thoại: ' + phone);
                });
            }
        });
    });

    // -------------------------------------------------------------------------
    // 3. Modal xem Chi tiết Khách hàng & Lịch sử Đặt sân
    // -------------------------------------------------------------------------
    const modal = document.getElementById('customerModal');
    if (!modal) return;

    const modalAvatar = document.getElementById('modalCustomerAvatar');
    const modalName = document.getElementById('modalCustomerName');
    const modalPhone = document.getElementById('modalCustomerPhone');
    const modalTypeBadge = document.getElementById('modalCustomerTypeBadge');
    const modalEmail = document.getElementById('modalCustomerEmail');
    const modalPhoneWrapper = document.getElementById('modalPhoneWrapper');
    const modalEmailWrapper = document.getElementById('modalEmailWrapper');
    const modalCopyPhoneBtn = document.getElementById('modalCopyPhoneBtn');

    const modalStatTotal = document.getElementById('modalStatTotal');
    const modalStatSuccess = document.getElementById('modalStatSuccess');
    const modalStatPending = document.getElementById('modalStatPending');
    const modalStatSpent = document.getElementById('modalStatSpent');
    const modalHistoryContent = document.getElementById('modalHistoryContent');

    let currentCustomerPhone = '';

    function openCustomerModal(customerKey) {
        if (!customerKey) return;
        const dataEl = document.getElementById('data-' + customerKey);
        if (!dataEl) return;

        const name = dataEl.dataset.name || 'Khách hàng';
        const initial = dataEl.dataset.initial || 'K';
        const avatarBg = dataEl.dataset.avatarBg || 'linear-gradient(135deg, #10b981, #059669)';
        const phone = dataEl.dataset.phone || 'Chưa có SĐT';
        const email = dataEl.dataset.email || '';
        const type = dataEl.dataset.type || 'Khách trực tiếp';

        currentCustomerPhone = phone;

        if (modalAvatar) {
            modalAvatar.textContent = initial;
            modalAvatar.style.background = avatarBg;
        }
        if (modalName) modalName.textContent = name;
        if (modalPhone) modalPhone.textContent = phone;
        if (modalTypeBadge) modalTypeBadge.textContent = type;

        if (modalEmail) {
            modalEmail.textContent = email || 'Chưa liên kết email';
        }
        if (modalEmailWrapper) {
            modalEmailWrapper.style.display = email ? 'inline-flex' : 'none';
        }

        if (modalStatTotal) modalStatTotal.textContent = dataEl.dataset.total || '0';
        if (modalStatSuccess) modalStatSuccess.textContent = dataEl.dataset.success || '0';
        if (modalStatPending) modalStatPending.textContent = dataEl.dataset.pending || '0';
        if (modalStatSpent) modalStatSpent.textContent = dataEl.dataset.spent || '0 đ';

        if (modalHistoryContent) {
            modalHistoryContent.innerHTML = dataEl.innerHTML;
        }

        modal.classList.add('is-open');
        modal.setAttribute('aria-hidden', 'false');
        document.body.style.overflow = 'hidden';
    }

    function closeCustomerModal() {
        modal.classList.remove('is-open');
        modal.setAttribute('aria-hidden', 'true');
        document.body.style.overflow = '';
    }

    if (modalCopyPhoneBtn) {
        modalCopyPhoneBtn.addEventListener('click', (e) => {
            e.stopPropagation();
            if (currentCustomerPhone && navigator.clipboard) {
                navigator.clipboard.writeText(currentCustomerPhone).then(() => {
                    showToast('Đã sao chép SĐT: ' + currentCustomerPhone);
                });
            }
        });
    }

    document.querySelectorAll('[data-open-modal]').forEach(btn => {
        btn.addEventListener('click', (e) => {
            e.stopPropagation();
            openCustomerModal(btn.getAttribute('data-open-modal'));
        });
    });

    document.querySelectorAll('[data-customer-row]').forEach(row => {
        row.addEventListener('click', (e) => {
            if (e.target.closest('button') || e.target.closest('a') || e.target.closest('form')) {
                return;
            }
            openCustomerModal(row.getAttribute('data-customer-key'));
        });
    });

    modal.querySelectorAll('[data-close-modal]').forEach(btn => {
        btn.addEventListener('click', closeCustomerModal);
    });

    modal.addEventListener('click', (e) => {
        if (e.target === modal) closeCustomerModal();
    });

    document.addEventListener('keydown', (e) => {
        if (e.key === 'Escape') {
            closeSidebar();
            if (modal.classList.contains('is-open')) closeCustomerModal();
        }
    });

    // -------------------------------------------------------------------------
    // 4. Tìm kiếm tức thì & Bộ lọc Tabs
    // -------------------------------------------------------------------------
    const searchInput = document.getElementById('customer-search-input');
    const rows = Array.from(document.querySelectorAll('[data-customer-row]'));
    const filterChips = document.querySelectorAll('[data-filter]');
    const summaryCountEl = document.getElementById('tableResultSummary');
    let currentFilter = 'all';

    function applyFilterAndSearch() {
        const query = searchInput ? searchInput.value.trim().toLowerCase() : '';
        let visibleCount = 0;

        rows.forEach(row => {
            const searchData = row.getAttribute('data-search') || '';
            const isFrequent = row.getAttribute('data-is-frequent') === 'true';
            const hasPending = row.getAttribute('data-has-pending') === 'true';
            const isRegistered = row.getAttribute('data-is-registered') === 'true';

            let matchesQuery = !query || searchData.includes(query);
            let matchesTab = true;

            if (currentFilter === 'pending') {
                matchesTab = hasPending;
            } else if (currentFilter === 'frequent') {
                matchesTab = isFrequent;
            } else if (currentFilter === 'registered') {
                matchesTab = isRegistered;
            }

            if (matchesQuery && matchesTab) {
                row.style.display = '';
                visibleCount++;
            } else {
                row.style.display = 'none';
            }
        });

        if (summaryCountEl) {
            summaryCountEl.innerHTML = `Hiển thị <strong>${visibleCount}</strong> khách hàng phù hợp`;
        }
    }

    if (searchInput) {
        searchInput.addEventListener('input', applyFilterAndSearch);
    }

    filterChips.forEach(chip => {
        chip.addEventListener('click', () => {
            filterChips.forEach(c => c.classList.remove('active'));
            chip.classList.add('active');
            currentFilter = chip.getAttribute('data-filter');
            applyFilterAndSearch();
        });
    });

    // Auto open if query matches view
    const urlParams = new URLSearchParams(window.location.search);
    const viewKey = urlParams.get('view');
    if (viewKey) {
        openCustomerModal(viewKey);
    }
});
