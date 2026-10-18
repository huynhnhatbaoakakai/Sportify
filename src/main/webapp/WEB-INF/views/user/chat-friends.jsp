<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="true" %>
<%@ page import="com.sportify.model.User" %>
<%
    String contextPath = request.getContextPath();
    User currentUser = (User) session.getAttribute("user");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chat với Bạn bè - Sportify</title>
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/style.css">
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/pages/chat-friends.css">
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/icons.css">
</head>
<body>


<% String activeMenu = "chat-friends"; %>
<%@ include file="/WEB-INF/views/common/sidebar.jspf" %>

    <!-- CHAT CONTAINER -->
    <div class="chat-container">
        <!-- Friends List -->
        <aside class="chat-sidebar">
            <div class="chat-sidebar-header">
                <h2><span class="app-icon icon-users" aria-hidden="true"></span> Bạn bè (<span id="friendCount">...</span>)</h2>
            </div>
            <div class="chat-list" id="chatList">
                <div style="padding:20px; color:#999; font-size:13px;">Đang tải danh sách...</div>
            </div>
        </aside>

        <!-- Chat Area -->
        <section class="chat-main">
            <div class="chat-header" style="justify-content:space-between;">
                <div style="display:flex; align-items:center; gap:12px;">
                    <div class="avatar" id="currentAvatar">?</div>
                    <div class="chat-header-info">
                        <h3 id="currentName">Chọn một người để nhắn tin</h3>
                        <div class="status" id="currentStatus"></div>
                    </div>
                </div>
                <button type="button" id="headerTransferBtn" onclick="openTransferBookingModal()"
                        style="display:none; align-items:center; gap:6px; background:linear-gradient(135deg,#0284c7,#0369a1); color:#fff; border:none; border-radius:10px; padding:8px 14px; font-size:13px; font-weight:700; cursor:pointer; box-shadow:0 4px 10px rgba(2,132,199,0.25);">
                    🎟️ Chuyển lịch đặt sân cho người này
                </button>
            </div>

            <div class="chat-messages" id="chatMessages">
                <div class="chat-empty"><span class="app-icon icon-arrow-left" aria-hidden="true"></span> Chọn một người bạn để bắt đầu trò chuyện</div>
            </div>

            <div id="statusBar"></div>

            <div class="chat-input-area" style="gap:10px;">
                <button type="button" id="transferBookingBtn" onclick="openTransferBookingModal()" disabled
                        title="Chuyển quyền sở hữu lịch đặt sân đã xác nhận cho tài khoản này"
                        style="display:inline-flex; align-items:center; gap:6px; background:#e0f2fe; color:#0369a1; border:1.5px solid #7dd3fc; border-radius:12px; padding:0 14px; height:44px; font-size:13px; font-weight:700; cursor:pointer; white-space:nowrap;">
                    🎟️ Chuyển lịch sân
                </button>
                <input type="text" id="messageInput" class="chat-input"
                       placeholder="Nhập tin nhắn... (Enter để gửi)"
                       onkeypress="handleEnter(event)" disabled>
                <button class="send-btn" id="sendBtn" aria-label="Gửi tin nhắn" onclick="sendMessage()" disabled><span class="app-icon icon-send" aria-hidden="true"></span></button>
            </div>
        </section>
    </div>

    <!-- MODAL CHUYỂN NHƯỢNG TÀI SẢN LỊCH ĐẶT SÂN QUA TIN NHẮN -->
    <div id="transferBookingModal" style="display:none; position:fixed; inset:0; background:rgba(15,23,42,0.55); z-index:9999; align-items:center; justify-content:center; padding:16px;">
        <div style="background:#fff; width:100%; max-width:560px; border-radius:18px; box-shadow:0 20px 50px rgba(0,0,0,0.25); overflow:hidden; display:flex; flex-direction:column; max-height:90vh;">
            <div style="background:linear-gradient(135deg,#0f172a,#1e293b); color:#fff; padding:18px 22px; display:flex; align-items:center; justify-content:space-between;">
                <div>
                    <h3 style="margin:0; font-size:17px; font-weight:800;">🎟️ Chuyển nhượng Tài sản Lịch Đặt Sân</h3>
                    <p style="margin:4px 0 0 0; font-size:12.5px; color:#cbd5e1;">Lịch sân đã xác nhận sẽ chuyển sang quyền sở hữu của tài khoản người nhận</p>
                </div>
                <button type="button" onclick="closeTransferBookingModal()" style="background:rgba(255,255,255,0.12); color:#fff; border:none; width:32px; height:32px; border-radius:8px; cursor:pointer; font-size:16px; font-weight:700;">✕</button>
            </div>

            <div style="padding:20px 22px; overflow-y:auto; display:flex; flex-direction:column; gap:16px;">
                <div>
                    <label style="display:block; font-size:13px; font-weight:700; color:#1e293b; margin-bottom:6px;">👤 Tài khoản nhận quyền sở hữu lịch sân:</label>
                    <select id="transferReceiverSelect" style="width:100%; padding:10px 12px; border:1.5px solid #cbd5e1; border-radius:10px; font-size:14px; font-weight:600; color:#0f172a; background:#f8fafc;">
                    </select>
                </div>

                <div>
                    <label style="display:block; font-size:13px; font-weight:700; color:#1e293b; margin-bottom:8px;">💎 Chọn lịch đặt sân đã xác nhận (Tài sản của bạn):</label>
                    <div id="transferBookingList" style="display:flex; flex-direction:column; gap:10px; max-height:260px; overflow-y:auto;">
                        <div style="padding:16px; text-align:center; color:#64748b; font-size:13px;">Đang tải kho tài sản lịch sân của bạn...</div>
                    </div>
                </div>

                <div>
                    <label style="display:block; font-size:13px; font-weight:700; color:#1e293b; margin-bottom:6px;">💬 Lời nhắn đính kèm khi chuyển sân:</label>
                    <input type="text" id="transferNoteInput" placeholder="VD: Mình nhượng lại lịch đặt sân này cho bạn nhé!"
                           style="width:100%; padding:10px 12px; border:1.5px solid #cbd5e1; border-radius:10px; font-size:13.5px; box-sizing:border-box;">
                </div>

                <div id="transferModalError" style="display:none; background:#fee2e2; color:#991b1b; padding:10px 12px; border-radius:10px; font-size:13px; font-weight:600;"></div>
            </div>

            <div style="padding:14px 22px; background:#f8fafc; border-top:1px solid #e2e8f0; display:flex; justify-content:flex-end; gap:10px;">
                <button type="button" onclick="closeTransferBookingModal()"
                        style="padding:9px 16px; border-radius:10px; border:1px solid #cbd5e1; background:#fff; color:#475569; font-weight:700; cursor:pointer;">
                    Hủy
                </button>
                <button type="button" id="confirmTransferBtn" onclick="submitBookingTransfer()"
                        style="padding:9px 18px; border-radius:10px; border:none; background:linear-gradient(135deg,#159447,#15803d); color:#fff; font-weight:800; cursor:pointer; box-shadow:0 4px 12px rgba(21,148,71,0.25);">
                    🎁 Xác nhận chuyển quyền sở hữu
                </button>
            </div>
        </div>
    </div>

<script>
    // Giá trị từ server cho file JS của trang
    const CTX = '<%= contextPath %>';
    const ME_ID = <%= currentUser.getId() %>;
</script>
<script src="<%= contextPath %>/assets/js/pages/chat-friends.js?v=<%= System.currentTimeMillis() %>"></script>
</body>
</html>
