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
    <title>Tin nhắn - Sportify</title>
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/style.css">
    <style>
        body {
            background: #f0f2f5;
            height: 100vh;
            display: flex;
            flex-direction: column;
            overflow: hidden;
        }
        
        .header { flex-shrink: 0; }

        .chat-layout {
            display: flex;
            flex: 1;
            max-width: 1200px;
            margin: 20px auto;
            width: 100%;
            height: calc(100vh - 110px);
            background: var(--white);
            border-radius: 12px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.05);
            overflow: hidden;
            border: 1px solid var(--border);
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
            transition: 0.2s;
        }

        .chat-search input:focus {
            border-color: var(--primary);
            background: var(--white);
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
            background: var(--border);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
            flex-shrink: 0;
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
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            font-size: 15px;
        }

        .chat-item-time {
            font-size: 12px;
            color: var(--muted);
            flex-shrink: 0;
        }

        .chat-item-role {
            font-size: 11px;
            padding: 2px 6px;
            border-radius: 4px;
            background: #eef2ff;
            color: #4f46e5;
            display: inline-block;
            margin-bottom: 4px;
            font-weight: 600;
        }
        
        .role-pt { background: #fee2e2; color: #dc2626; }
        .role-shop { background: #fef3c7; color: #d97706; }
        .role-court { background: #dcfce7; color: #16a34a; }

        .chat-item-preview {
            font-size: 13px;
            color: var(--muted);
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

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
            position: relative;
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

        .attach-btn {
            background: none;
            border: none;
            font-size: 24px;
            color: var(--muted);
            cursor: pointer;
            transition: 0.2s;
        }

        .attach-btn:hover { color: var(--primary); }

        .chat-input {
            flex: 1;
            padding: 12px 20px;
            border: 1px solid var(--border);
            border-radius: 25px;
            background: #f8faf9;
            outline: none;
            font-size: 15px;
            transition: 0.2s;
        }

        .chat-input:focus {
            border-color: var(--primary);
            background: var(--white);
        }

        .send-btn {
            background: var(--primary);
            color: var(--white);
            border: none;
            width: 45px;
            height: 45px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: 0.2s;
            font-size: 18px;
        }

        .send-btn:hover {
            background: var(--primary-dark);
            transform: scale(1.05);
        }
        
        .date-divider {
            text-align: center;
            margin: 15px 0;
            position: relative;
        }
        
        .date-divider span {
            background: var(--background);
            padding: 0 15px;
            font-size: 12px;
            color: var(--muted);
            position: relative;
            z-index: 1;
        }
        
        .date-divider::before {
            content: '';
            position: absolute;
            left: 0;
            top: 50%;
            width: 100%;
            height: 1px;
            background: var(--border);
            z-index: 0;
        }
    </style>
</head>
<body>

<header class="header">
    <div class="container navbar" style="min-height: 60px;">
        <a class="brand" href="<%= contextPath %>/home.jsp">
            <span class="brand-icon" style="width: 30px; height: 30px; font-size: 16px;">S</span>
            <span style="font-size: 18px;">SPORTIFY</span>
        </a>
        <nav class="nav-links">
            <a href="<%= contextPath %>/home.jsp">Trang chủ</a>
            <a href="#">Lịch đặt</a>
            <a href="#" style="color: var(--primary); font-weight: bold;">Tin nhắn</a>
        </nav>
        <div style="display: flex; align-items: center; gap: 10px;">
            <div class="avatar" style="width: 35px; height: 35px; font-size: 16px; background: var(--primary-light); color: var(--primary);">
                K
            </div>
            <span style="font-size: 14px; font-weight: 600;">Khách hàng</span>
        </div>
    </div>
</header>

<main class="chat-layout">
    <!-- Sidebar -->
    <aside class="chat-sidebar">
        <div class="chat-sidebar-header">
            <h2>Tin nhắn Dịch vụ</h2>
        </div>
        <div class="chat-search">
            <input type="text" placeholder="Tìm kiếm hội thoại...">
        </div>
        
        <div class="chat-list" id="chatList">
            <!-- Items rendered via JS -->
        </div>
    </aside>

    <!-- Main Chat -->
    <section class="chat-main">
        <div class="chat-header">
            <div class="avatar avatar-online" id="currentChatAvatar">🏢</div>
            <div class="chat-header-info">
                <h3><span id="currentChatName">Sân bóng Sunrise</span> <span class="chat-item-role role-court" id="currentChatRole" style="font-size: 10px; margin-left: 8px;">Chủ sân</span></h3>
                <div class="status">Đang hoạt động</div>
            </div>
        </div>

        <div class="chat-messages" id="chatMessages">
            <!-- Messages rendered via JS -->
        </div>

        <div class="chat-input-area">
            <button class="attach-btn" title="Đính kèm hình ảnh/file">📎</button>
            <input type="text" id="messageInput" class="chat-input" placeholder="Nhập tin nhắn..." onkeypress="handleEnter(event)">
            <button class="send-btn" title="Gửi" onclick="sendMessage()">➤</button>
        </div>
    </section>
</main>



</body>
</html>


<script>
    // Mock Data cho các cuộc hội thoại
    const conversations = [
        {
            id: 'c1',
            name: 'Sân bóng Sunrise',
            icon: '🏢',
            roleName: 'Chủ sân',
            roleClass: 'role-court',
            time: '10:45',
            online: true,
            messages: [
                { type: 'divider', text: 'Hôm nay' },
                { sender: 'me', text: 'Chào bạn, cho mình hỏi tối nay (khoảng 19h) sân 5 bên bạn còn trống không ạ?', time: '10:30' },
                { sender: 'them', text: 'Chào bạn! Để mình kiểm tra lịch một chút nhé.', time: '10:32' },
                { sender: 'them', text: 'Vâng ạ, sân 5 người đang trống vào lúc 19h tối nay nhé bạn. Bạn có muốn đặt luôn không ạ? Giá là 250k/giờ.', time: '10:45' },
                { sender: 'me', text: 'Tuyệt quá, bạn đặt cho mình từ 19h đến 20h30 nhé. Tên mình là Khoa.', time: '10:46' }
            ]
        },
        {
            id: 'c2',
            name: 'PT Nguyễn Minh Anh',
            icon: '💪',
            roleName: 'Huấn luyện viên',
            roleClass: 'role-pt',
            time: 'Hôm qua',
            online: false,
            messages: [
                { type: 'divider', text: 'Hôm qua' },
                { sender: 'them', text: 'Chào Khoa, lịch tập gym tuần này của mình là thứ 3, thứ 5 và thứ 7 nhé.', time: '08:00' },
                { sender: 'me', text: 'Ok anh, em sẽ đến đúng giờ.', time: '08:15' },
                { sender: 'them', text: 'Bạn nhớ uống đủ nước trước buổi tập ngày mai nhé!', time: '20:30' }
            ]
        },
        {
            id: 'c3',
            name: 'Sport Gear Q7',
            icon: '🎒',
            roleName: 'Shop dụng cụ',
            roleClass: 'role-shop',
            time: 'Thứ 2',
            online: true,
            messages: [
                { type: 'divider', text: 'Thứ 2' },
                { sender: 'me', text: 'Shop ơi, bên mình còn vợt Pickleball loại carbon không?', time: '14:00' },
                { sender: 'them', text: 'Dạ còn anh nhé, vợt Pickleball loại anh hỏi đã có hàng rồi ạ. Giá thuê là 50k/ngày.', time: '14:20' }
            ]
        }
    ];

    let currentConversationId = 'c1';

    function renderChatList() {
        const chatListEl = document.getElementById('chatList');
        chatListEl.innerHTML = '';

        conversations.forEach(conv => {
            const lastMsg = conv.messages.filter(m => m.type !== 'divider').slice(-1)[0];
            const previewText = lastMsg ? lastMsg.text : '...';
            
            const div = document.createElement('div');
            div.className = `chat-item \${conv.id == currentConversationId ? 'active' : ''}`;
            div.onclick = () => selectConversation(conv.id);
            
            div.innerHTML = `
                <div class="avatar \${conv.online ? 'avatar-online' : ''}">\${conv.icon}</div>
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
        if(!conv) return;

        conv.messages.forEach(msg => {
            if (msg.type === 'divider') {
                chatMessagesEl.innerHTML += `
                    <div class="date-divider">
                        <span>\${msg.text}</span>
                    </div>
                `;
            } else {
                const isSent = msg.sender === 'me';
                chatMessagesEl.innerHTML += `
                    <div class="message \${isSent ? 'message-sent' : 'message-received'}">
                        <div class="message-bubble">\${msg.text}</div>
                        <div class="message-time">\${msg.time}</div>
                    </div>
                `;
            }
        });
        
        chatMessagesEl.scrollTop = chatMessagesEl.scrollHeight;
    }

    function updateHeader() {
        const conv = conversations.find(c => c.id === currentConversationId);
        if(!conv) return;
        
        document.getElementById('currentChatAvatar').innerText = conv.icon;
        if(conv.online) {
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

    function sendMessage() {
        const input = document.getElementById('messageInput');
        const text = input.value.trim();
        if (text === '') return;

        const conv = conversations.find(c => c.id === currentConversationId);
        if (conv) {
            const now = new Date();
            const timeStr = \`\${now.getHours().toString().padStart(2,'0')}:\${now.getMinutes().toString().padStart(2,'0')}\`;
            
            conv.messages.push({
                sender: 'me',
                text: text,
                time: timeStr
            });
            conv.time = timeStr; // update preview time
            
            input.value = '';
            renderChatList();
            renderMessages();
        }
    }

    function handleEnter(event) {
        if (event.key === 'Enter') {
            sendMessage();
        }
    }

    // Initialize
    window.onload = () => {
        renderChatList();
        updateHeader();
        renderMessages();
    };
</script>
</body>
</html>
