// Thông tin người đang đăng nhập (từ server)
const API = CTX + '/chat-api';

let friends = [];       // danh sách bạn bè với messages
let currentFriendId = null;
const requestedFriendId = new URLSearchParams(window.location.search).get('friendId');
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

    } catch (e) {
        document.getElementById('chatList').innerHTML =
            '<div style="padding:15px;color:red;font-size:12px;">Không kết nối được API: ' + e.message + '</div>';
    }
}

// ===== RENDER DANH SÁCH BẠN BÈ =====
function renderList() {
    const listEl = document.getElementById('chatList');
    listEl.innerHTML = '';

    friends.forEach(f => {
        const msgs = f.messages || [];
        const last = msgs.length > 0 ? msgs[msgs.length - 1] : null;
        const preview = last ? (last.sender == ME_ID ? 'Bạn: ' : '') + last.text : 'Chưa có tin nhắn';
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
        msgEl.innerHTML = '<div class="chat-empty">Chưa có tin nhắn nào. Hãy gửi tin đầu tiên!</div>';
        return;
    }

    msgEl.innerHTML = msgs.map(msg => {
        const isMine = String(msg.sender) === String(ME_ID);
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
    if (!f) {
        document.getElementById('currentAvatar').textContent = '?';
        document.getElementById('currentName').textContent = 'Chọn một người để nhắn tin';
        document.getElementById('currentStatus').textContent = '';
        document.getElementById('messageInput').disabled = true;
        document.getElementById('sendBtn').disabled = true;
    } else {
        const initial = f.partnerIcon || f.partnerName[0].toUpperCase();
        const headerRole = f.roleName === 'Chủ sân'
            ? '<span class="badge-role-owner" style="font-size:11.5px;padding:2px 8px;background:#dcfce7;color:#15803d;border-radius:6px;margin-left:8px;font-weight:700;">🏟️ Chủ sân • Phục vụ đơn hàng</span>' : '';
        document.getElementById('currentAvatar').textContent = initial;
        document.getElementById('currentName').innerHTML = escHtml(f.partnerName) + headerRole;
        document.getElementById('currentStatus').textContent = 'Tin nhắn trực tiếp';
        document.getElementById('messageInput').disabled = false;
        document.getElementById('sendBtn').disabled = false;
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
