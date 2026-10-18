// Thông tin người đang đăng nhập (từ server)
const API = CTX + '/chat-api';

let friends = [];       // danh sách bạn bè với messages
let currentFriendId = null;
const urlParams = new URLSearchParams(window.location.search);
const requestedFriendId = urlParams.get('friendId');
let pendingTransferBookingId = urlParams.get('transferBookingId');
let myConfirmedAssets = [];
let pollingTimer = null;

// ===== LOAD FRIENDS FROM API =====
async function loadFriends(keepCurrent) {
    try {
        const res = await fetch(API + '?action=getFriends');
        if (res.status === 401) { window.location.href = CTX + '/login'; return; }

        const data = await res.json();
        if (data.error) {
            document.getElementById('chatList').innerHTML =
                '<div style="padding:15px;color:red;font-size:12px;">Lỗi: ' + data.error + '</div>';
            return;
        }

        friends = data;
        document.getElementById('friendCount').textContent = friends.length;

        if (friends.length === 0) {
            document.getElementById('chatList').innerHTML =
                '<div style="padding:20px;color:#999;font-size:13px;">Chưa có tài khoản nào khác trong hệ thống.</div>';
            return;
        }

        // Mở đúng chủ sân/khách hàng khi đi từ sân hoặc đơn đặt sân.
        if (!keepCurrent && !currentFriendId && friends.length > 0) {
            const requestedFriend = friends.find(friend => String(friend.id) === requestedFriendId);
            currentFriendId = requestedFriend ? requestedFriend.id : friends[0].id;
        }

        renderList();
        renderMessages();
        updateHeader();

        // Nếu đi từ trang chủ bấm "Chuyển qua Tin nhắn" (?transferBookingId=...)
        if (pendingTransferBookingId) {
            const toOpenId = pendingTransferBookingId;
            pendingTransferBookingId = null;
            openTransferBookingModal(toOpenId);
        }

    } catch (e) {
        document.getElementById('chatList').innerHTML =
            '<div style="padding:15px;color:red;font-size:12px;">Không kết nối được API: ' + e.message + '</div>';
    }
}

function parseTransferPayload(text) {
    if (!text || !text.startsWith('[BOOKING_ASSET_TRANSFER|') || !text.endsWith(']')) {
        return null;
    }
    const inner = text.substring('[BOOKING_ASSET_TRANSFER|'.length, text.length - 1);
    const parts = inner.split('|');
    if (parts.length < 10) return null;
    return {
        bookingId: parts[0],
        bookingCode: parts[1],
        fieldName: parts[2],
        sportType: parts[3],
        courtNumber: parts[4],
        dateStr: parts[5],
        timeStr: parts[6],
        priceFormatted: parts[7],
        senderName: parts[8],
        receiverName: parts[9],
        note: parts.slice(10).join('|')
    };
}

function formatPreviewText(text) {
    const parsed = parseTransferPayload(text);
    if (parsed) {
        return '🎟️ Chuyển lịch sân #' + parsed.bookingCode + ' (' + parsed.fieldName + ')';
    }
    return text || '';
}

// ===== RENDER DANH SÁCH BẠN BÈ =====
function renderList() {
    const listEl = document.getElementById('chatList');
    listEl.innerHTML = '';

    friends.forEach(f => {
        const msgs = f.messages || [];
        const last = msgs.length > 0 ? msgs[msgs.length - 1] : null;
        const preview = last ? (last.sender == ME_ID ? 'Bạn: ' : '') + formatPreviewText(last.text) : 'Chưa có tin nhắn';
        const time = last ? last.time : '';
        const initial = f.partnerIcon || (f.partnerName ? f.partnerName[0].toUpperCase() : '?');
        const roleBadge = f.roleName === 'Chủ sân'
            ? '<span class="badge-role-owner" style="font-size:10px;padding:1px 5px;background:#dcfce7;color:#15803d;border-radius:4px;margin-left:4px;font-weight:700;">🏟️ Chủ sân</span>' : '';

        const div = document.createElement('div');
        div.className = 'chat-item' + (f.id == currentFriendId ? ' active' : '');
        div.onclick = () => selectFriend(f.id);
        div.innerHTML = `
            <div class="avatar">${escHtml(initial)}</div>
            <div class="chat-item-content">
                <div class="chat-item-header">
                    <span class="chat-item-name">${escHtml(f.partnerName)}${roleBadge}</span>
                    <span class="chat-item-time">${escHtml(time)}</span>
                </div>
                <div class="chat-item-preview">${escHtml(preview)}</div>
            </div>`;
        listEl.appendChild(div);
    });
}

// ===== RENDER MESSAGES =====
function renderMessages() {
    const msgEl = document.getElementById('chatMessages');
    if (!currentFriendId) {
        msgEl.innerHTML = '<div class="chat-empty">← Chọn một người bạn để bắt đầu trò chuyện</div>';
        return;
    }

    const f = friends.find(x => x.id == currentFriendId);
    if (!f) { msgEl.innerHTML = ''; return; }

    const msgs = f.messages || [];
    if (msgs.length === 0) {
        msgEl.innerHTML = '<div class="chat-empty">Chưa có tin nhắn nào. Hãy gửi tin đầu tiên hoặc bấm <b>🎟️ Chuyển lịch sân</b>!</div>';
        return;
    }

    msgEl.innerHTML = msgs.map(msg => {
        const isMine = String(msg.sender) === String(ME_ID);
        const transfer = parseTransferPayload(msg.text);
        if (transfer) {
            return `<div class="message ${isMine ? 'message-sent' : 'message-received'}" style="max-width:420px;">
                        <div style="background:linear-gradient(145deg,#ffffff,#f0fdf4); border:2px solid #22c55e; border-radius:16px; padding:14px 16px; color:#0f172a; box-shadow:0 6px 18px rgba(21,128,61,0.12);">
                            <div style="display:flex; align-items:center; justify-content:space-between; gap:8px; margin-bottom:8px;">
                                <span style="background:#15803d; color:#fff; font-size:10.5px; font-weight:800; padding:3px 9px; border-radius:999px;">
                                    🎟️ CHUYỂN NHƯỢNG TÀI SẢN LỊCH SÂN
                                </span>
                                <span style="font-size:12px; font-weight:800; color:#15803d;">#${escHtml(transfer.bookingCode)}</span>
                            </div>
                            <div style="font-size:15px; font-weight:800; color:#0f172a; margin-bottom:6px;">
                                🏟️ ${escHtml(transfer.fieldName)} (Sân #${escHtml(transfer.courtNumber)})
                            </div>
                            <div style="font-size:12.5px; color:#334155; display:flex; flex-direction:column; gap:4px; background:#fff; padding:9px 11px; border-radius:10px; border:1px solid #dcfce7; margin-bottom:8px;">
                                <div>📅 <b>Ngày đặt:</b> ${escHtml(transfer.dateStr)}</div>
                                <div>🕒 <b>Khung giờ:</b> ${escHtml(transfer.timeStr)}</div>
                                <div>💰 <b>Giá trị vé sân:</b> <span style="color:#15803d;font-weight:800;">${escHtml(transfer.priceFormatted)}</span></div>
                                <div>🔄 <b>Chuyển quyền sở hữu:</b> ${escHtml(transfer.senderName)} → <b style="color:#0284c7;">${escHtml(transfer.receiverName)}</b></div>
                            </div>
                            ${transfer.note ? `<div style="font-size:12.5px; font-style:italic; color:#475569; margin-bottom:8px;">💬 "${escHtml(transfer.note)}"</div>` : ''}
                            <a href="${CTX}/home#my-booking-assets" style="display:block; text-align:center; background:#15803d; color:#fff; text-decoration:none; padding:7px 12px; border-radius:9px; font-size:12px; font-weight:700;">
                                💎 Xem trong Kho tài sản lịch sân →
                            </a>
                        </div>
                        <div class="message-time">${escHtml(msg.time)}</div>
                    </div>`;
        }
        return `<div class="message ${isMine ? 'message-sent' : 'message-received'}">
                    <div class="message-bubble">${escHtml(msg.text)}</div>
                    <div class="message-time">${escHtml(msg.time)}</div>
                </div>`;
    }).join('');

    msgEl.scrollTop = msgEl.scrollHeight;
}

// ===== UPDATE HEADER =====
function updateHeader() {
    const f = currentFriendId ? friends.find(x => x.id == currentFriendId) : null;
    const transferBtn = document.getElementById('transferBookingBtn');
    const headerTransferBtn = document.getElementById('headerTransferBtn');
    if (!f) {
        document.getElementById('currentAvatar').textContent = '?';
        document.getElementById('currentName').textContent = 'Chọn một người để nhắn tin';
        document.getElementById('currentStatus').textContent = '';
        document.getElementById('messageInput').disabled = true;
        document.getElementById('sendBtn').disabled = true;
        if (transferBtn) transferBtn.disabled = true;
        if (headerTransferBtn) headerTransferBtn.style.display = 'none';
    } else {
        const initial = f.partnerIcon || f.partnerName[0].toUpperCase();
        const headerRole = f.roleName === 'Chủ sân'
            ? '<span class="badge-role-owner" style="font-size:11.5px;padding:2px 8px;background:#dcfce7;color:#15803d;border-radius:6px;margin-left:8px;font-weight:700;">🏟️ Chủ sân • Phục vụ đơn hàng</span>' : '';
        document.getElementById('currentAvatar').textContent = initial;
        document.getElementById('currentName').innerHTML = escHtml(f.partnerName) + headerRole;
        document.getElementById('currentStatus').textContent = 'Tin nhắn trực tiếp • Có thể chuyển nhượng lịch đặt sân';
        document.getElementById('messageInput').disabled = false;
        document.getElementById('sendBtn').disabled = false;
        if (transferBtn) transferBtn.disabled = false;
        if (headerTransferBtn) headerTransferBtn.style.display = 'inline-flex';
        document.getElementById('messageInput').focus();
    }
}

// ===== CHỌN NGƯỜI BẠN =====
function selectFriend(id) {
    currentFriendId = id;
    renderList();
    renderMessages();
    updateHeader();
}

// ===== GỬI TIN NHẮN =====
async function sendMessage() {
    const input = document.getElementById('messageInput');
    const text = input.value.trim();
    if (!text || !currentFriendId) return;

    const now = new Date();
    const timeStr = now.getHours().toString().padStart(2,'0') + ':' + now.getMinutes().toString().padStart(2,'0');

    // Hiển thị ngay (optimistic)
    const f = friends.find(x => x.id == currentFriendId);
    if (!f.messages) f.messages = [];
    f.messages.push({ sender: ME_ID, text: text, time: timeStr });
    input.value = '';
    renderMessages();

    // Gửi lên server
    const body = new URLSearchParams({
        action: 'sendFriendMessage',
        receiverId: currentFriendId,
        text: text,
        time: timeStr
    });

    try {
        const res = await fetch(API, { method: 'POST', body: body });
        const data = await res.json();
        if (data.error) {
            document.getElementById('statusBar').textContent = 'Lỗi gửi: ' + data.error;
        } else {
            document.getElementById('statusBar').textContent = '';
        }
    } catch (e) {
        document.getElementById('statusBar').textContent = 'Không thể gửi: ' + e.message;
    }
}

function handleEnter(e) {
    if (e.key === 'Enter') sendMessage();
}

// ===== MODAL CHUYỂN NHƯỢNG TÀI SẢN LỊCH ĐẶT SÂN =====
async function openTransferBookingModal(preselectBookingId) {
    const modal = document.getElementById('transferBookingModal');
    const errEl = document.getElementById('transferModalError');
    const receiverSelect = document.getElementById('transferReceiverSelect');
    const listEl = document.getElementById('transferBookingList');
    const confirmBtn = document.getElementById('confirmTransferBtn');

    errEl.style.display = 'none';
    modal.style.display = 'flex';

    // Populate receiver select
    receiverSelect.innerHTML = friends.map(f =>
        `<option value="${f.id}" ${f.id == currentFriendId ? 'selected' : ''}>${escHtml(f.partnerName)} (${escHtml(f.roleName || 'Thành viên')})</option>`
    ).join('');

    listEl.innerHTML = '<div style="padding:16px; text-align:center; color:#64748b; font-size:13px;">⏳ Đang tải danh sách lịch đặt sân đã xác nhận của bạn...</div>';

    try {
        const res = await fetch(API + '?action=getMyConfirmedBookings');
        const data = await res.json();
        myConfirmedAssets = Array.isArray(data) ? data : [];

        if (myConfirmedAssets.length === 0) {
            listEl.innerHTML = `
                <div style="padding:18px; text-align:center; background:#f8fafc; border:1.5px dashed #cbd5e1; border-radius:12px; color:#475569; font-size:13px;">
                    📭 Bạn hiện không có lịch đặt sân nào ở trạng thái <b>Đã xác nhận (CONFIRMED)</b> để chuyển nhượng.<br>
                    <a href="${CTX}/home#fields" style="display:inline-block; margin-top:8px; color:#15803d; font-weight:700;">+ Đặt sân mới ngay</a>
                </div>`;
            confirmBtn.disabled = true;
            confirmBtn.style.opacity = '0.5';
            return;
        }

        confirmBtn.disabled = false;
        confirmBtn.style.opacity = '1';

        const selectedId = preselectBookingId || myConfirmedAssets[0].bookingId;
        listEl.innerHTML = myConfirmedAssets.map(b => {
            const checked = String(b.bookingId) === String(selectedId) ? 'checked' : '';
            return `
                <label style="display:flex; align-items:flex-start; gap:12px; padding:12px 14px; border:2px solid #bbf7d0; background:#f0fdf4; border-radius:12px; cursor:pointer;">
                    <input type="radio" name="transferBookingRadio" value="${b.bookingId}" ${checked} style="margin-top:4px; transform:scale(1.2);">
                    <div style="flex:1;">
                        <div style="display:flex; align-items:center; justify-content:space-between; gap:8px;">
                            <span style="font-weight:800; color:#0f172a; font-size:14.5px;">🏟️ ${escHtml(b.fieldName)} (Sân #${b.courtNumber})</span>
                            <span style="background:#15803d; color:#fff; font-size:11px; font-weight:800; padding:2px 8px; border-radius:999px;">#${escHtml(b.bookingCode)}</span>
                        </div>
                        <div style="font-size:12.5px; color:#334155; margin-top:4px;">
                            📅 <b>${escHtml(b.dateStr)}</b> • 🕒 <b>${escHtml(b.timeStr)}</b> • 💰 <b style="color:#15803d;">${escHtml(b.priceFormatted)}</b>
                        </div>
                    </div>
                </label>`;
        }).join('');
    } catch (e) {
        listEl.innerHTML = '<div style="padding:12px; color:#dc2626; font-size:13px;">Không thể tải danh sách lịch đặt sân: ' + escHtml(e.message) + '</div>';
    }
}

function closeTransferBookingModal() {
    document.getElementById('transferBookingModal').style.display = 'none';
}

async function submitBookingTransfer() {
    const errEl = document.getElementById('transferModalError');
    const receiverSelect = document.getElementById('transferReceiverSelect');
    const checkedRadio = document.querySelector('input[name="transferBookingRadio"]:checked');
    const noteInput = document.getElementById('transferNoteInput');
    const confirmBtn = document.getElementById('confirmTransferBtn');

    if (!receiverSelect || !receiverSelect.value) {
        errEl.textContent = 'Vui lòng chọn người nhận.';
        errEl.style.display = 'block';
        return;
    }
    if (!checkedRadio || !checkedRadio.value) {
        errEl.textContent = 'Vui lòng chọn một lịch đặt sân đã xác nhận để chuyển nhượng.';
        errEl.style.display = 'block';
        return;
    }

    const receiverId = receiverSelect.value;
    const bookingId = checkedRadio.value;
    const note = noteInput.value.trim() || 'Mình chuyển quyền sở hữu lịch đặt sân này cho bạn nhé!';

    const now = new Date();
    const timeStr = now.getHours().toString().padStart(2,'0') + ':' + now.getMinutes().toString().padStart(2,'0');

    confirmBtn.disabled = true;
    confirmBtn.textContent = 'Đang chuyển quyền sở hữu...';
    errEl.style.display = 'none';

    try {
        const body = new URLSearchParams({
            action: 'transferBooking',
            bookingId: bookingId,
            receiverId: receiverId,
            note: note,
            time: timeStr
        });

        const res = await fetch(API, { method: 'POST', body: body });
        const data = await res.json();

        confirmBtn.disabled = false;
        confirmBtn.textContent = '🎁 Xác nhận chuyển quyền sở hữu';

        if (data.error) {
            errEl.textContent = data.error;
            errEl.style.display = 'block';
            return;
        }

        currentFriendId = Number(receiverId);
        noteInput.value = '';
        closeTransferBookingModal();
        await loadFriends(true);
    } catch (e) {
        confirmBtn.disabled = false;
        confirmBtn.textContent = '🎁 Xác nhận chuyển quyền sở hữu';
        errEl.textContent = 'Lỗi kết nối: ' + e.message;
        errEl.style.display = 'block';
    }
}

// Escape HTML để tránh XSS
function escHtml(str) {
    if (!str) return '';
    return String(str)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;');
}

// ===== POLLING: Cứ 2 giây reload tin nhắn =====
function startPolling() {
    pollingTimer = setInterval(() => loadFriends(true), 2000);
}

// ===== KHỞI ĐỘNG =====
window.onload = function() {
    loadFriends(false);
    startPolling();
};
