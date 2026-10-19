/**
 * SPORTIFY - ORDER SERVICE CHAT JAVASCRIPT
 * Xử lý mở modal, tải dữ liệu đơn hàng, tin nhắn thời gian thực và gửi tin nhắn
 * Tương thích với database FriendMessages (đồng bộ tài khoản giữa Khách và Chủ sân)
 */

(function () {
    let currentBookingId = null;
    let currentPartnerId = null;
    let pollTimer = null;
    let lastMessageCount = -1;
    let isSending = false;
    let isInitialLoad = true;

    // Lấy contextPath an toàn
    function getContextPath() {
        if (typeof window.CTX !== 'undefined' && window.CTX) return window.CTX;
        const path = window.location.pathname;
        const firstSlash = path.indexOf('/', 1);
        return firstSlash > 0 ? path.substring(0, firstSlash) : '';
    }

    function esc(str) {
        if (!str) return '';
        const div = document.createElement('div');
        div.textContent = str;
        return div.innerHTML;
    }

    // Mở Modal Chat phục vụ đơn hàng
    window.openOrderChat = function (bookingId, partnerId) {
        if (!bookingId) {
            console.error('openOrderChat: bookingId is required');
            return;
        }

        currentBookingId = bookingId;
        currentPartnerId = partnerId || null;
        lastMessageCount = -1;
        isInitialLoad = true;

        const modal = document.getElementById('orderChatModal');
        if (!modal) {
            console.error('Không tìm thấy element #orderChatModal');
            return;
        }

        modal.classList.add('is-open');
        modal.setAttribute('aria-hidden', 'false');
        document.body.style.overflow = 'hidden';

        // Reset ô tin nhắn
        const input = document.getElementById('orderChatMessageInput');
        if (input) {
            input.value = '';
            input.disabled = false;
        }

        // Tải dữ liệu lần đầu
        loadOrderChatData();

        // Bắt đầu chu kỳ polling tự động mỗi 2.5s để cập nhật tin nhắn mới
        if (pollTimer) clearInterval(pollTimer);
        pollTimer = setInterval(loadOrderChatData, 2500);

        // Focus vào ô nhập khi mở
        setTimeout(() => {
            if (input) input.focus();
        }, 300);
    };

    // Đóng Modal Chat
    window.closeOrderChatModal = function () {
        if (pollTimer) {
            clearInterval(pollTimer);
            pollTimer = null;
        }

        const modal = document.getElementById('orderChatModal');
        if (modal) {
            modal.classList.remove('is-open');
            modal.setAttribute('aria-hidden', 'true');
        }
        document.body.style.overflow = '';
        currentBookingId = null;
        currentPartnerId = null;
        lastMessageCount = -1;
    };

    // Tải dữ liệu đơn hàng và lịch sử tin nhắn từ API
    async function loadOrderChatData() {
        if (!currentBookingId) return;

        const ctx = getContextPath();
        let url = ctx + '/chat-api?action=getOrderChat&bookingId=' + encodeURIComponent(currentBookingId);
        if (currentPartnerId) {
            url += '&partnerId=' + encodeURIComponent(currentPartnerId);
        }

        try {
            const res = await fetch(url, {
                headers: { 'Accept': 'application/json' }
            });

            if (res.status === 401) {
                window.location.href = ctx + '/login';
                return;
            }

            if (!res.ok) {
                throw new Error('HTTP ' + res.status);
            }

            const data = await res.json();
            if (data.error) {
                renderError(data.error);
                return;
            }

            // Cập nhật thông tin đối tác & ghim đơn hàng
            updateHeaderAndOrderInfo(data);

            // Cập nhật gợi ý tin nhắn nhanh
            updateQuickChips(data.isOwnerViewing);

            // Cập nhật danh sách tin nhắn
            updateMessageStream(data);

            isInitialLoad = false;
        } catch (err) {
            console.error('Lỗi khi tải dữ liệu order chat:', err);
            if (isInitialLoad) {
                renderError('Không thể kết nối đến máy chủ: ' + err.message);
            }
        }
    }

    // Hiển thị thông tin đối tác và thẻ thông tin đơn hàng được ghim
    function updateHeaderAndOrderInfo(data) {
        const p = data.partner || {};
        const b = data.booking || {};
        currentPartnerId = p.id;

        // Header
        const partnerNameEl = document.getElementById('orderChatPartnerName');
        const partnerRoleEl = document.getElementById('orderChatPartnerRole');
        const partnerAvatarEl = document.getElementById('orderChatPartnerAvatar');
        const statusTextEl = document.getElementById('orderChatStatusText');

        if (partnerNameEl) partnerNameEl.textContent = p.name || 'Người dùng';
        if (partnerRoleEl) {
            partnerRoleEl.textContent = p.role || 'Thành viên';
            if (p.role === 'Chủ sân') {
                partnerRoleEl.style.background = '#dcfce7';
                partnerRoleEl.style.color = '#15803d';
            } else {
                partnerRoleEl.style.background = '#e0f2fe';
                partnerRoleEl.style.color = '#0369a1';
            }
        }
        if (partnerAvatarEl) partnerAvatarEl.textContent = p.initial || (p.name ? p.name.substring(0, 1).toUpperCase() : 'U');
        if (statusTextEl) {
            statusTextEl.textContent = 'Trực tuyến • Hỗ trợ đơn #' + (b.bookingCode || b.bookingId);
        }

        // Pinned Order Card
        const codeEl = document.getElementById('orderContextCode');
        const venueEl = document.getElementById('orderContextVenue');
        const sportEl = document.getElementById('orderContextSport');
        const statusEl = document.getElementById('orderContextStatus');
        const timeEl = document.getElementById('orderContextTime');
        const priceEl = document.getElementById('orderContextPrice');
        const contactEl = document.getElementById('orderContextContact');

        if (codeEl) codeEl.textContent = '#' + (b.bookingCode || b.bookingId);
        if (venueEl) venueEl.textContent = b.fieldName || 'Sân thể thao';
        if (sportEl) sportEl.textContent = b.sportType || 'SPORT';

        if (statusEl) {
            statusEl.textContent = b.statusLabel || b.status || 'Chờ xác nhận';
            statusEl.className = 'context-status-pill';
            const st = (b.status || '').toUpperCase();
            if (st === 'CONFIRMED') {
                statusEl.classList.add('status-confirmed');
            } else if (st === 'PENDING') {
                statusEl.classList.add('status-pending');
            } else if (st === 'COMPLETED') {
                statusEl.classList.add('status-completed');
            } else if (st === 'REJECTED' || st === 'CANCELLED') {
                statusEl.classList.add('status-cancelled');
            }
        }

        if (timeEl) {
            let timeStr = '';
            if (b.startsAt) timeStr += b.startsAt;
            if (b.endsAt) timeStr += ' - ' + b.endsAt;
            timeEl.textContent = timeStr || 'Thời gian đặt sân';
        }

        if (priceEl) priceEl.textContent = b.totalPrice || '0 đ';

        if (contactEl) {
            let contactStr = b.customerName || 'Khách hàng';
            if (b.customerPhone) contactStr += ' • ' + b.customerPhone;
            contactEl.textContent = contactStr;
        }
    }

    // Cập nhật chip gợi ý tin nhắn nhanh
    function updateQuickChips(isOwnerViewing) {
        const chipsContainer = document.getElementById('orderChatQuickChips');
        if (!chipsContainer || chipsContainer.dataset.rendered === (isOwnerViewing ? 'owner' : 'cust')) {
            return;
        }

        const ownerChips = [
            'Chào bạn, shop đã nhận được yêu cầu đặt sân của bạn.',
            'Sân đã sẵn sàng, mời bạn đến trước 10 phút để nhận sân nhé!',
            'Bạn có cần chuẩn bị thêm bóng, áo tập hay nước uống không ạ?',
            'Khung giờ này sân đang bảo trì, bạn đổi sang giờ khác được không?'
        ];

        const customerChips = [
            'Chào chủ sân, mình muốn xác nhận thông tin đơn đặt lịch này ạ.',
            'Cho mình hỏi bên sân có sẵn bóng và áo pitch cho mượn không ạ?',
            'Khoảng mấy giờ thì bên mình có thể vào sân nhận sân được vậy shop?',
            'Mình có thể đến sớm hơn 15 phút để khởi động được không?'
        ];

        const chips = isOwnerViewing ? ownerChips : customerChips;
        chipsContainer.innerHTML = '';
        chipsContainer.dataset.rendered = isOwnerViewing ? 'owner' : 'cust';

        chips.forEach(chipText => {
            const btn = document.createElement('button');
            btn.type = 'button';
            btn.className = 'order-chat-chip-btn';
            btn.textContent = chipText;
            btn.onclick = () => {
                const input = document.getElementById('orderChatMessageInput');
                if (input) {
                    input.value = chipText;
                    input.focus();
                }
            };
            chipsContainer.appendChild(btn);
        });
    }

    // Hiển thị dòng tin nhắn trong hộp thoại
    function updateMessageStream(data) {
        const stream = document.getElementById('orderChatMessagesArea');
        if (!stream) return;

        const messages = data.messages || [];
        const currentUserId = String(data.currentUserId);
        const partnerName = (data.partner && data.partner.name) ? data.partner.name : 'Người nhận';
        const partnerInitial = (data.partner && data.partner.initial) ? data.partner.initial : 'U';

        // Nếu số lượng tin nhắn không đổi và không phải tải lần đầu, không re-render để tránh giật
        if (messages.length === lastMessageCount && !isInitialLoad) {
            return;
        }
        lastMessageCount = messages.length;

        if (messages.length === 0) {
            stream.innerHTML = `
                <div class="chat-empty-state">
                    <span class="material-symbols-rounded empty-icon app-icon icon-chat" aria-hidden="true"></span>
                    <h5>Bắt đầu trò chuyện phục vụ đơn hàng</h5>
                    <p>Hai bên có thể trao đổi thông tin nhận sân, thời gian, thiết bị hoặc các yêu cầu đặc biệt tại đây. Tin nhắn được lưu an toàn vào tài khoản của bạn.</p>
                </div>
            `;
            return;
        }

        let html = '';
        let lastDate = '';

        messages.forEach(msg => {
            const isMine = String(msg.sender) === currentUserId;
            const bubbleClass = isMine ? 'bubble-sent' : 'bubble-received';
            const rowClass = isMine ? 'msg-row-sent' : 'msg-row-received';

            html += `
                <div class="chat-message-row ${rowClass}">
                    ${!isMine ? `<div class="msg-partner-avatar" title="${esc(partnerName)}">${esc(partnerInitial)}</div>` : ''}
                    <div class="chat-bubble ${bubbleClass}">
                        ${!isMine ? `<div class="msg-sender-name">${esc(partnerName)}</div>` : ''}
                        <div class="msg-text-content">${esc(msg.text)}</div>
                        <div class="msg-meta-row">
                            <span class="msg-timestamp">${esc(msg.time)}</span>
                            ${isMine ? `<span class="material-symbols-rounded msg-check-icon app-icon icon-check" aria-hidden="true"></span>` : ''}
                        </div>
                    </div>
                </div>
            `;
        });

        stream.innerHTML = html;

        // Tự động cuộn xuống tin nhắn mới nhất
        setTimeout(() => {
            stream.scrollTop = stream.scrollHeight;
        }, 50);
    }

    function renderError(msg) {
        const stream = document.getElementById('orderChatMessagesArea');
        if (stream) {
            stream.innerHTML = `
                <div class="chat-empty-state" style="color: #ef4444;">
                    <span class="material-symbols-rounded empty-icon app-icon icon-alert" style="color: #ef4444; background: #fee2e2;" aria-hidden="true"></span>
                    <h5>Có lỗi xảy ra</h5>
                    <p>${esc(msg)}</p>
                </div>
            `;
        }
    }

    // Gửi tin nhắn
    window.sendOrderChatMessage = async function () {
        if (isSending) return;

        const input = document.getElementById('orderChatMessageInput');
        const sendBtn = document.getElementById('orderChatSendBtn');
        if (!input) return;

        const text = input.value.trim();
        if (!text) {
            input.focus();
            return;
        }

        if (!currentPartnerId) {
            alert('Chưa xác định được người nhận tin nhắn. Vui lòng thử lại sau giây lát.');
            return;
        }

        const ctx = getContextPath();
        const now = new Date();
        const timeStr = String(now.getHours()).padStart(2, '0') + ':' +
                        String(now.getMinutes()).padStart(2, '0') + ' ' +
                        String(now.getDate()).padStart(2, '0') + '/' +
                        String(now.getMonth() + 1).padStart(2, '0');

        isSending = true;
        if (sendBtn) sendBtn.disabled = true;

        try {
            const params = new URLSearchParams();
            params.append('action', 'sendOrderMessage');
            params.append('receiverId', currentPartnerId);
            params.append('text', text);
            params.append('time', timeStr);

            const res = await fetch(ctx + '/chat-api', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
                    'Accept': 'application/json'
                },
                body: params.toString()
            });

            if (res.status === 401) {
                window.location.href = ctx + '/login';
                return;
            }

            const data = await res.json();
            if (data.status === 'success' || data.success) {
                input.value = '';
                // Tải lại tin nhắn ngay để hiển thị
                await loadOrderChatData();
            } else {
                alert('Không thể gửi tin nhắn: ' + (data.error || 'Lỗi không xác định'));
            }
        } catch (err) {
            console.error('Lỗi khi gửi tin nhắn:', err);
            alert('Không thể gửi tin nhắn. Vui lòng kiểm tra lại kết nối mạng.');
        } finally {
            isSending = false;
            if (sendBtn) sendBtn.disabled = false;
            if (input) {
                input.disabled = false;
                input.focus();
            }
        }
    };

    // Mở đơn hàng gần nhất của khách
    window.openLatestOrderChat = function () {
        if (window.FIRST_CUSTOMER_BOOKING_ID) {
            openOrderChat(window.FIRST_CUSTOMER_BOOKING_ID);
        } else {
            window.location.href = getContextPath() + '/chat-friends';
        }
    };

    // Kiểm tra tin nhắn mới từ chủ sân để kích hoạt banner thông báo nổi bật
    async function checkForOwnerMessages() {
        const alertEl = document.getElementById('orderChatCustomerAlert');
        const dotEl = document.getElementById('floatingUnreadDot');
        if (!alertEl && !dotEl) return;

        const ctx = getContextPath();
        try {
            const res = await fetch(ctx + '/chat-api?action=getFriends');
            if (!res.ok) return;
            const friends = await res.json();
            if (!Array.isArray(friends)) return;

            let latestOwnerChat = null;
            let latestOwnerMsg = null;

            for (const f of friends) {
                const isOwner = (f.roleName === 'Chủ sân') || f.id === 1 || f.id === 7;
                const msgs = f.messages || [];
                if (isOwner && msgs.length > 0) {
                    const last = msgs[msgs.length - 1];
                    if (String(last.sender) === String(f.id)) {
                        latestOwnerChat = f;
                        latestOwnerMsg = last;
                        break;
                    }
                }
            }

            if (latestOwnerChat && latestOwnerMsg) {
                if (alertEl) {
                    const nameEl = document.getElementById('liveAlertPartnerName');
                    const snippetEl = document.getElementById('liveAlertSnippet');
                    if (nameEl) nameEl.textContent = latestOwnerChat.partnerName || 'Chủ sân';
                    if (snippetEl) snippetEl.textContent = '"' + latestOwnerMsg.text + '" • ' + (latestOwnerMsg.time || '');
                    alertEl.style.display = 'flex';
                }
                if (dotEl) {
                    dotEl.style.display = 'block';
                }
            }
        } catch (e) {
            console.debug('checkForOwnerMessages:', e);
        }
    }

    // Đăng ký sự kiện phím tắt và click ngoài
    document.addEventListener('DOMContentLoaded', function () {
        // Lắng nghe sự kiện Enter trên input
        const input = document.getElementById('orderChatMessageInput');
        if (input) {
            input.addEventListener('keydown', function (e) {
                if (e.key === 'Enter' && !e.shiftKey) {
                    e.preventDefault();
                    sendOrderChatMessage();
                }
            });
        }

        // Đóng modal khi click ra backdrop ngoài dialog
        const modal = document.getElementById('orderChatModal');
        if (modal) {
            modal.addEventListener('click', function (e) {
                if (e.target === modal) {
                    closeOrderChatModal();
                }
            });
        }

        // Đóng modal khi nhấn Escape
        document.addEventListener('keydown', function (e) {
            if (e.key === 'Escape' || e.key === 'Esc') {
                const modal = document.getElementById('orderChatModal');
                if (modal && modal.classList.contains('is-open')) {
                    closeOrderChatModal();
                }
            }
        });

        // Kiểm tra thông báo tin nhắn từ chủ sân
        checkForOwnerMessages();
    });
})();


