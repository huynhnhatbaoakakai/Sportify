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

        const filterButtons = Array.from(document.querySelectorAll('[data-status-filter]'));
        const bookingSearch = document.querySelector('[data-booking-search]');
        const bookingResult = document.querySelector('[data-booking-result]');
        const emptyState = document.querySelector('[data-empty-state]');
        const emptyTitle = emptyState.querySelector('strong');
        const emptyMessage = emptyState.querySelector('p');
        const statusLabels = {
            pending: 'chờ xác nhận',
            confirmed: 'đã xác nhận',
            completed: 'đã hoàn thành',
            rejected: 'đã từ chối',
            cancelled: 'đã hủy'
        };
        let activeFilter = 'all';

        function normalizeSearch(value) {
            return value.toLocaleLowerCase('vi-VN').normalize('NFD')
                .replace(/[\u0300-\u036f]/g, '').replace(/đ/g, 'd');
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
            if (visible === 0 && document.querySelector('#booking-section').dataset.bookingLoadFailed !== 'true') {
                emptyTitle.textContent = query ? 'Không tìm thấy đơn phù hợp'
                    : activeFilter === 'all' ? 'Chưa có đơn đặt sân'
                    : `Chưa có đơn ${statusLabels[activeFilter] || 'phù hợp'}`;
                emptyMessage.textContent = query ? 'Hãy thử từ khóa khác hoặc chọn Tất cả.'
                    : activeFilter === 'all' ? 'Đơn đặt sân sẽ xuất hiện tại đây.'
                    : 'Bộ lọc đang hoạt động. Hiện chưa có đơn ở trạng thái này.';
            }
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

        document.querySelector('[data-booking-body]').addEventListener('submit', event => {
            const form = event.target.closest('[data-booking-action-form]');
            if (!form) return;
            const row = form.closest('[data-booking-row]');
            row.querySelectorAll('button').forEach(button => { button.disabled = true; });
            form.querySelector('button').textContent = 'Đang lưu...';
        });

        window.addEventListener('pageshow', () => {
            document.querySelectorAll('[data-booking-action-form]').forEach(form => {
                const button = form.querySelector('button');
                button.disabled = false;
                const action = form.querySelector('[name="status"]').value;
                button.textContent = action === 'CONFIRMED' ? 'Xác nhận' : action === 'COMPLETED' ? 'Xác nhận đã sử dụng' : 'Từ chối';
            });
        });

        document.querySelector('.notification-button').addEventListener('click', () => {
            const loadFailed = document.querySelector('#booking-section').dataset.bookingLoadFailed === 'true';
            const pending = Number(document.querySelector('[data-pending-count]').dataset.pendingValue);
            showToast(loadFailed ? 'Chưa tải được lịch đặt. Vui lòng tải lại trang.'
                : `Bạn có ${pending} yêu cầu chờ xác nhận.`);
        });

        const fieldGrid = document.querySelector('[data-fields-grid]');
        const fieldModal = document.querySelector('[data-field-modal]');
        const fieldForm = document.querySelector('[data-field-form]');
        const fieldTitle = document.querySelector('[data-field-modal-title]');
        const fieldSubmit = document.querySelector('[data-field-submit]');
        const fieldIdInput =
            fieldForm.querySelector('[data-field-id-input]');
        const nameInput = fieldForm.querySelector('[name="fieldName"]');
        const sportInput = fieldForm.querySelector('[name="sportType"]');
        const addressInput = fieldForm.querySelector('[name="address"]');
        const priceInput = fieldForm.querySelector('[name="pricePerHour"]');
        const openTimeInput =
            fieldForm.querySelector('[name="openTime"]');
        const closeTimeInput =
            fieldForm.querySelector('[name="closeTime"]');
        const statusInput = fieldForm.querySelector('[name="status"]');
        const quantityInput = fieldForm.querySelector('[name="quantity"]');
        let returnFocus = null;

        function updateActiveFieldCount() {
            document.querySelector('[data-active-field-count]').textContent =
                fieldGrid.querySelectorAll('[data-field-card][data-status="active"]').length;
        }

        function openFieldModal(card) {
            returnFocus = document.activeElement;
            fieldForm.reset();
            fieldTitle.textContent = card ? 'Chỉnh sửa sân' : 'Thêm sân';
            fieldSubmit.textContent = card ? 'Lưu thay đổi' : 'Thêm sân';
            if (card) {
                fieldForm.action = fieldForm.dataset.updateAction;
                fieldIdInput.value = card.dataset.fieldId;
                nameInput.value = card.querySelector('[data-field-name]').textContent;
                sportInput.value = card.dataset.sportType;
                addressInput.value = card.querySelector('[data-field-address]').textContent;
                priceInput.value = card.dataset.price;
                openTimeInput.value = card.dataset.openTime;
                closeTimeInput.value = card.dataset.closeTime;
                statusInput.value = card.dataset.status === 'active' ? 'ACTIVE' : 'INACTIVE';
                if (quantityInput) {
                    quantityInput.value = card.dataset.quantity || '4';
                }
            } else {
                fieldForm.action = fieldForm.dataset.createAction;
                fieldIdInput.value = '';
                if (quantityInput) {
                    quantityInput.value = '4';
                }
            }
            fieldModal.hidden = false;
            body.classList.add('modal-open');
            nameInput.focus();
        }

        function closeFieldModal() {
            fieldModal.hidden = true;
            body.classList.remove('modal-open');
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
            if (!event.target.closest('[data-field-edit]')) return;
            const card = event.target.closest('[data-field-card]');
            if (!card) return;
            openFieldModal(card);
        });

        fieldGrid.addEventListener('submit', event => {
            const toggleForm = event.target.closest('[data-field-toggle-form]');
            if (!toggleForm) return;

            const toggleButton = toggleForm.querySelector('[data-field-toggle]');
            toggleButton.disabled = true;
            toggleButton.textContent = 'Đang cập nhật...';
        });

        fieldForm.addEventListener('submit', event => {
            if (openTimeInput.value && closeTimeInput.value
                && closeTimeInput.value <= openTimeInput.value) {
                event.preventDefault();
                showToast('Giờ đóng cửa phải sau giờ mở cửa.');
                closeTimeInput.focus();
                return;
            }

            fieldSubmit.disabled = true;
            fieldSubmit.textContent = 'Đang lưu...';
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

        updateActiveFieldCount();
        filterBookings();
    });
