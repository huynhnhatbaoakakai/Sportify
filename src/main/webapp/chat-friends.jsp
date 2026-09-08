<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>
<%
    String contextPath = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chat với bạn bè - Sportify</title>
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/style.css">
    <style>
        body {
            background: var(--background);
            display: flex;
            height: 100vh;
            overflow: hidden;
        }

        /* SIDEBAR NAVIGATION */
        .sidebar {
            width: 280px;
            background: var(--white);
            border-right: 1px solid var(--border);
            display: flex;
            flex-direction: column;
            padding: 20px 0;
            flex-shrink: 0;
        }

        .sidebar-brand {
            padding: 0 25px 20px;
            margin-bottom: 10px;
            border-bottom: 1px solid var(--border);
        }

        .sidebar-menu {
            display: flex;
            flex-direction: column;
            gap: 10px;
            padding: 0 15px;
        }

        .menu-item {
            display: flex;
            align-items: center;
            gap: 15px;
            padding: 12px 20px;
            border-radius: 12px;
            color: var(--text);
            font-weight: 600;
            transition: 0.2s;
        }

        .menu-item:hover, .menu-item.active {
            background: var(--primary-light);
            color: var(--primary);
        }

        .menu-icon { font-size: 20px; }

        /* CHAT LAYOUT */
        .chat-container {
            flex: 1;
            display: flex;
            background: var(--white);
            margin: 20px;
            border-radius: 16px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.05);
            border: 1px solid var(--border);
            overflow: hidden;
        }

        .chat-sidebar {
            width: 320px;
            background: #fff;
            border-right: 1px solid var(--border);
            display: flex;
            flex-direction: column;
        }

        .chat-sidebar-header {
            padding: 20px;
            border-bottom: 1px solid var(--border);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .chat-sidebar-header h2 { font-size: 20px; color: var(--dark); }

        .chat-search {
            padding: 15px 20px;
            border-bottom: 1px solid var(--border);
        }

        .chat-search input {
            width: 100%;
            padding: 10px 15px;
            border-radius: 20px;
            border: 1px solid var(--border);
            background: var(--background);
            outline: none;
        }

        .chat-list {
            flex: 1;
            overflow-y: auto;
        }

        .chat-item {
            display: flex;
            padding: 15px 20px;
            gap: 15px;
            cursor: pointer;
            transition: background 0.2s;
            border-bottom: 1px solid #f5f5f5;
        }

        .chat-item:hover, .chat-item.active {
            background: var(--primary-light);
        }

        .avatar {
            width: 48px;
            height: 48px;
            border-radius: 50%;
            background: var(--primary-light);
            color: var(--primary);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 18px;
            font-weight: bold;
            position: relative;
        }
        
        .avatar-online::after {
            content: '';
            position: absolute;
            width: 12px;
            height: 12px;
            background: #10b981;
            border-radius: 50%;
            bottom: 0;
            right: 0;
            border: 2px solid #fff;
        }

        .chat-item-content {
            flex: 1;
            min-width: 0;
        }

        .chat-item-header {
            display: flex;
            justify-content: space-between;
            margin-bottom: 4px;
        }

        .chat-item-name {
            font-weight: 600;
            color: var(--dark);
            font-size: 15px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .chat-item-time {
            font-size: 12px;
            color: var(--muted);
            flex-shrink: 0;
        }

        .chat-item-preview {
            font-size: 13px;
            color: var(--muted);
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        /* MAIN CHAT AREA */
        .chat-main {
            flex: 1;
            display: flex;
            flex-direction: column;
            background: var(--background);
        }

        .chat-header {
            padding: 15px 25px;
            background: var(--white);
            border-bottom: 1px solid var(--border);
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .chat-header-info h3 {
            font-size: 18px;
            color: var(--dark);
            margin-bottom: 4px;
        }
        
        .chat-header-info .status {
            font-size: 13px;
            color: #10b981;
        }

        .chat-messages {
            flex: 1;
            padding: 25px;
            overflow-y: auto;
            display: flex;
            flex-direction: column;
            gap: 15px;
        }

        .message {
            display: flex;
            flex-direction: column;
            max-width: 65%;
        }

        .message-received { align-self: flex-start; }
        .message-sent { align-self: flex-end; align-items: flex-end; }

        .message-bubble {
            padding: 12px 18px;
            border-radius: 18px;
            font-size: 15px;
            line-height: 1.5;
        }

        .message-received .message-bubble {
            background: var(--white);
            color: var(--text);
            border: 1px solid var(--border);
            border-bottom-left-radius: 4px;
        }

        .message-sent .message-bubble {
            background: var(--primary);
            color: var(--white);
            border-bottom-right-radius: 4px;
        }
        
        .message-time {
            font-size: 11px;
            color: var(--muted);
            margin-top: 4px;
            margin-left: 5px;
            margin-right: 5px;
        }

        .chat-input-area {
            padding: 20px 25px;
            background: var(--white);
            border-top: 1px solid var(--border);
            display: flex;
            gap: 15px;
            align-items: center;
        }

        .chat-input {
            flex: 1;
            padding: 12px 20px;
            border: 1px solid var(--border);
            border-radius: 25px;
            background: #f8faf9;
            outline: none;
            font-size: 15px;
        }

        .send-btn {
            background: var(--primary);
            color: var(--white);
            border: none;
            width: 45px;
            height: 45px;
            border-radius: 50%;
            cursor: pointer;
            font-size: 18px;
            display: flex;
            align-items: center;
            justify-content: center;
        }
    </style>
</head>
<body>

    <!-- SIDEBAR NAVIGATION -->
    <aside class="sidebar">
        <div class="sidebar-brand">
            <a class="brand" href="<%= contextPath %>/home.jsp">
                <span class="brand-icon">S</span>
                <span>SPORTIFY</span>
            </a>
        </div>
        
        <nav class="sidebar-menu">
            <a href="<%= contextPath %>/home.jsp" class="menu-item">
                <span class="menu-icon">🏠</span>
                <span>Trang chủ</span>
            </a>
            
            <div style="margin: 15px 0 5px 20px; font-size: 12px; color: var(--muted); font-weight: bold; text-transform: uppercase;">
                Giao tiếp
            </div>
            
            <a href="<%= contextPath %>/chat.jsp" class="menu-item">
                <span class="menu-icon">💬</span>
                <span>Chat với Dịch vụ</span>
            </a>
            
            <a href="<%= contextPath %>/chat-friends.jsp" class="menu-item active">
                <span class="menu-icon">👥</span>
                <span>Chat với Bạn bè</span>
            </a>
            
            <div style="margin: 15px 0 5px 20px; font-size: 12px; color: var(--muted); font-weight: bold; text-transform: uppercase;">
                Cá nhân
            </div>
            
            <a href="<%= contextPath %>/profile.jsp" class="menu-item">
                <span class="menu-icon">👤</span>
                <span>Hồ sơ cá nhân</span>
            </a>
        </nav>
    </aside>

    <!-- CHAT CONTAINER -->
    <div class="chat-container">
        <!-- Friends List -->
        <aside class="chat-sidebar">
            <div class="chat-sidebar-header">
                <h2>Bạn bè</h2>
                <button style="border:none; background:none; font-size: 20px; color:var(--primary); cursor:pointer;">+</button>
            </div>
            <div class="chat-search">
                <input type="text" placeholder="Tìm bạn bè...">
            </div>
            
            <div class="chat-list" id="chatList">
                <!-- Items rendered via JS -->
            </div>
        </aside>

        <!-- Chat Area -->
        <section class="chat-main">
            <div class="chat-header">
                <div class="avatar avatar-online" id="currentChatAvatar">T</div>
                <div class="chat-header-info">
                    <h3 id="currentChatName">Trần Văn Nam</h3>
                    <div class="status" id="currentChatStatus">Đang hoạt động</div>
                </div>
            </div>

            <div class="chat-messages" id="chatMessages">
                <!-- Messages rendered via JS -->
            </div>

            <div class="chat-input-area">
                <input type="text" id="messageInput" class="chat-input" placeholder="Nhập tin nhắn..." onkeypress="handleEnter(event)">
                <button class="send-btn" onclick="sendMessage()">➤</button>
            </div>
        </section>
    </div>

<script>
    // Mock Data cho chat bạn bè
    const friendsConversations = [
        {
            id: 'f1',
            name: 'Trần Văn Nam',
            initial: 'T',
            time: 'Vừa xong',
            online: true,
            messages: [
                { sender: 'them', text: 'Ông book sân Sunrise tối nay chưa?', time: '10:48' },
                { sender: 'me', text: 'Vừa book xong, sân 5 người lúc 19h.', time: '10:50' },
                { sender: 'them', text: 'Ngon, nhớ rủ thằng Hoàng đi luôn. Tối nay 7h ra sân nhé!', time: 'Vừa xong' }
            ]
        },
        {
            id: 'f2',
            name: 'Hoàng Lê',
            initial: 'H',
            time: '10:20',
            online: false,
            messages: [
                { sender: 'me', text: 'Ê tối nay 7h đá bóng sân Sunrise nha mậy.', time: '10:15' },
                { sender: 'them', text: 'Ok chốt kèo.', time: '10:20' }
            ]
        },
        {
            id: 'f3',
            name: 'Nhóm Pickleball Q7',
            initial: 'M',
            time: 'Hôm qua',
            online: true,
            isGroup: true,
            messages: [
                { sender: 'them', text: 'Mai có ai rảnh không?', time: '20:00' },
                { sender: 'them', text: 'Ra đánh vài sec cho ra mồ hôi.', time: '20:01' },
                { sender: 'me', text: 'Mai em bận rồi mấy anh ơi.', time: '20:30' }
            ]
        }
    ];

    let currentConvId = 'f1';

    function renderFriendList() {
        const listEl = document.getElementById('chatList');
        listEl.innerHTML = '';

        friendsConversations.forEach(conv => {
            const lastMsg = conv.messages.slice(-1)[0];
            const preview = lastMsg ? lastMsg.text : '...';
            
            const div = document.createElement('div');
            div.className = `chat-item \${conv.id == currentConvId ? 'active' : ''}`;
            div.onclick = () => selectConv(conv.id);
            
            div.innerHTML = `
                <div class="avatar \${conv.online ? 'avatar-online' : ''}">\${conv.initial}</div>
                <div class="chat-item-content">
                    <div class="chat-item-header">
                        <span class="chat-item-name">\${conv.name}</span>
                        <span class="chat-item-time">\${conv.time}</span>
                    </div>
                    <div class="chat-item-preview">\${preview}</div>
                </div>
            `;
            listEl.appendChild(div);
        });
    }

    function renderFriendMessages() {
        const msgEl = document.getElementById('chatMessages');
        msgEl.innerHTML = '';
        
        const conv = friendsConversations.find(c => c.id === currentConvId);
        if(!conv) return;

        conv.messages.forEach(msg => {
            const isSent = msg.sender === 'me';
            msgEl.innerHTML += `
                <div class="message \${isSent ? 'message-sent' : 'message-received'}">
                    <div class="message-bubble">\${msg.text}</div>
                    <div class="message-time">\${msg.time}</div>
                </div>
            `;
        });
        
        msgEl.scrollTop = msgEl.scrollHeight;
    }

    function updateFriendHeader() {
        const conv = friendsConversations.find(c => c.id === currentConvId);
        if(!conv) return;
        
        document.getElementById('currentChatAvatar').innerText = conv.initial;
        if(conv.online) {
            document.getElementById('currentChatAvatar').classList.add('avatar-online');
            document.getElementById('currentChatStatus').innerText = 'Đang hoạt động';
        } else {
            document.getElementById('currentChatAvatar').classList.remove('avatar-online');
            document.getElementById('currentChatStatus').innerText = 'Ngoại tuyến';
        }
        document.getElementById('currentChatName').innerText = conv.name;
    }

    function selectConv(id) {
        currentConvId = id;
        renderFriendList();
        updateFriendHeader();
        renderFriendMessages();
    }

    function sendMessage() {
        const input = document.getElementById('messageInput');
        const text = input.value.trim();
        if (text === '') return;

        const conv = friendsConversations.find(c => c.id === currentConvId);
        if (conv) {
            const now = new Date();
            const timeStr = \`\${now.getHours().toString().padStart(2,'0')}:\${now.getMinutes().toString().padStart(2,'0')}\`;
            
            conv.messages.push({
                sender: 'me',
                text: text,
                time: timeStr
            });
            conv.time = timeStr;
            
            input.value = '';
            renderFriendList();
            renderFriendMessages();
        }
    }

    function handleEnter(event) {
        if (event.key === 'Enter') {
            sendMessage();
        }
    }

    window.onload = () => {
        renderFriendList();
        updateFriendHeader();
        renderFriendMessages();
    };
</script>

</body>
</html>

