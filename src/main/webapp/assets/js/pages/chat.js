let conversations = [];
let currentConversationId = null;

async function loadConversations() {
    try {
        const res = await fetch(CTX + '/chat-api?action=getConversations');
        if (res.status === 401) {
            window.location.href = CTX + '/login';
            return;
        }
        conversations = await res.json();

        // Map keys from DB schema to UI schema
        conversations.forEach(c => {
            c.icon = c.partnerIcon;
            c.name = c.partnerName;
            if (!c.messages) c.messages = [];
            // Find latest time
            if (c.messages.length > 0) {
                c.time = c.messages[c.messages.length - 1].time;
            } else {
                c.time = 'Mới';
            }
        });

        if (conversations.length > 0 && !currentConversationId) {
            currentConversationId = conversations[0].id;
        }
        renderChatList();
        updateHeader();
        renderMessages();
    } catch(e) {
        console.error('Lỗi tải tin nhắn:', e);
    }
}

function renderChatList() {
    const chatListEl = document.getElementById('chatList');
    chatListEl.innerHTML = '';

    conversations.forEach(conv => {
        const lastMsg = conv.messages.slice(-1)[0];
        const previewText = lastMsg ? lastMsg.text : 'Bắt đầu trò chuyện...';

        const div = document.createElement('div');
        div.className = `chat-item \${conv.id == currentConversationId ? 'active' : ''}`;
        div.onclick = () => selectConversation(conv.id);

        div.innerHTML = `
            <div class="avatar \${conv.isOnline ? 'avatar-online' : ''}">\${conv.icon}</div>
            <div class="chat-item-content">
                <div class="chat-item-header">
                    <span class="chat-item-name">\${conv.name}</span>
                    <span class="chat-item-time">\${conv.time}</span>
                </div>
                <span class="chat-item-role \${conv.roleClass}">\${conv.roleName}</span>
                <div class="chat-item-preview">\${previewText}</div>
            </div>
        `;
        chatListEl.appendChild(div);
    });
}

function renderMessages() {
    const chatMessagesEl = document.getElementById('chatMessages');
    chatMessagesEl.innerHTML = '';

    const conv = conversations.find(c => c.id === currentConversationId);
    if(!conv || !conv.messages) return;

    conv.messages.forEach(msg => {
        const isSent = msg.sender === 'me';
        chatMessagesEl.innerHTML += `
            <div class="message \${isSent ? 'message-sent' : 'message-received'}">
                <div class="message-bubble">\${msg.text}</div>
                <div class="message-time">\${msg.time}</div>
            </div>
        `;
    });

    chatMessagesEl.scrollTop = chatMessagesEl.scrollHeight;
}

function updateHeader() {
    const conv = conversations.find(c => c.id === currentConversationId);
    if(!conv) return;

    document.getElementById('currentChatAvatar').innerText = conv.icon;
    if(conv.isOnline) {
        document.getElementById('currentChatAvatar').classList.add('avatar-online');
    } else {
        document.getElementById('currentChatAvatar').classList.remove('avatar-online');
    }
    document.getElementById('currentChatName').innerText = conv.name;

    const roleEl = document.getElementById('currentChatRole');
    roleEl.innerText = conv.roleName;
    roleEl.className = `chat-item-role \${conv.roleClass}`;
}

function selectConversation(id) {
    currentConversationId = id;
    renderChatList();
    updateHeader();
    renderMessages();
}

async function sendMessage() {
    const input = document.getElementById('messageInput');
    const text = input.value.trim();
    if (text === '') return;

    const conv = conversations.find(c => c.id === currentConversationId);
    if (!conv) return;

    const now = new Date();
    const timeStr = \`\${now.getHours().toString().padStart(2,'0')}:\${now.getMinutes().toString().padStart(2,'0')}\`;

    // Optimistic UI update
    conv.messages.push({
        sender: 'me',
        text: text,
        time: timeStr
    });
    conv.time = timeStr;
    input.value = '';
    renderChatList();
    renderMessages();

    // Send to server
    const formData = new URLSearchParams();
    formData.append('action', 'sendMessage');
    formData.append('sessionId', conv.id);
    formData.append('text', text);
    formData.append('time', timeStr);

    try {
        const res = await fetch(CTX + '/chat-api', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: formData.toString()
        });

        // Reload conversations to get the reply from bot
        setTimeout(loadConversations, 500);

    } catch(e) {
        console.error(e);
    }
}

function handleEnter(event) {
    if (event.key === 'Enter') {
        sendMessage();
    }
}

// Initialize
window.onload = () => {
    loadConversations();

    // Auto refresh every 5 seconds to get new messages (if any)
    setInterval(loadConversations, 5000);
};
