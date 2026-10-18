const API = CTX + '/newsfeed-api';

let myConfirmedBookings = [];
let selectedBookingAsset = null;
let selectedPostPurpose = 'TIM_DOI';

const urlQuery = new URLSearchParams(window.location.search);
const initialShareBookingId = urlQuery.get('shareBookingId');
const initialPurpose = urlQuery.get('purpose');
if (initialPurpose === 'PASS_SAN' || initialPurpose === 'TIM_DOI') {
    selectedPostPurpose = initialPurpose;
}

// ===== ESCAPE HTML =====
function esc(str) {
    if (!str) return '';
    return String(str)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;');
}

// ===== LOAD MY CONFIRMED BOOKINGS FOR ATTACHMENT =====
async function loadMyBookingsForAttach(autoSelectId) {
    try {
        const res = await fetch(API + '?action=getMyBookings');
        const data = await res.json();
        myConfirmedBookings = Array.isArray(data) ? data : [];
        renderBookingSelectorList();

        if (autoSelectId) {
            const found = myConfirmedBookings.find(b => String(b.bookingId) === String(autoSelectId));
            if (found) {
                selectBookingToAttach(found.bookingId, selectedPostPurpose, true);
            }
        }
    } catch (e) {
        console.error('Không thể tải lịch đặt sân:', e);
    }
}

function toggleBookingSelector(forceState) {
    const panel = document.getElementById('bookingSelectorPanel');
    if (!panel) return;
    const show = forceState !== undefined ? forceState : (panel.style.display === 'none');
    panel.style.display = show ? 'block' : 'none';
    if (show) {
        loadMyBookingsForAttach(null);
    }
}

function renderBookingSelectorList() {
    const listEl = document.getElementById('myConfirmedBookingsList');
    if (!listEl) return;

    if (!myConfirmedBookings || myConfirmedBookings.length === 0) {
        listEl.innerHTML = `
            <div style="padding:14px; text-align:center; background:#fff; border:1px dashed #cbd5e1; border-radius:10px; color:#64748b; font-size:13px;">
                📭 Bạn hiện chưa có lịch đặt sân nào ở trạng thái <b>Đã xác nhận (CONFIRMED)</b> để đính kèm.<br>
                <a href="${CTX}/home#fields" style="display:inline-block; margin-top:6px; color:#15803d; font-weight:700;">+ Đặt sân ngay tại Trang chủ</a>
            </div>`;
        return;
    }

    listEl.innerHTML = myConfirmedBookings.map(b => {
        const isSelected = selectedBookingAsset && String(selectedBookingAsset.bookingId) === String(b.bookingId);
        return `
            <div style="display:flex; align-items:center; justify-content:space-between; gap:10px; padding:10px 12px; background:${isSelected ? '#dcfce7' : '#ffffff'}; border:1.5px solid ${isSelected ? '#16a34a' : '#e2e8f0'}; border-radius:10px;">
                <div>
                    <div style="font-weight:800; color:#0f172a; font-size:13.5px;">
                        🏟️ ${esc(b.fieldName)} (Sân #${b.courtNumber})
                        <span style="background:#15803d; color:#fff; font-size:10.5px; padding:2px 7px; border-radius:999px; margin-left:6px;">#${esc(b.bookingCode)}</span>
                    </div>
                    <div style="font-size:12px; color:#475569; margin-top:3px;">
                        📅 ${esc(b.dateStr)} • 🕒 ${esc(b.timeStr)} • 💰 <b style="color:#15803d;">${esc(b.priceFormatted)}</b>
                    </div>
                </div>
                <div style="display:flex; gap:6px; flex-wrap:wrap;">
                    <button type="button" onclick="selectBookingToAttach(${b.bookingId}, 'TIM_DOI', true)"
                            style="background:#159447; color:#fff; border:none; border-radius:8px; padding:6px 10px; font-size:12px; font-weight:700; cursor:pointer;">
                        🤝 Rủ hội nhóm
                    </button>
                    <button type="button" onclick="selectBookingToAttach(${b.bookingId}, 'PASS_SAN', true)"
                            style="background:#ea580c; color:#fff; border:none; border-radius:8px; padding:6px 10px; font-size:12px; font-weight:700; cursor:pointer;">
                        🏷️ Rao bán sân
                    </button>
                </div>
            </div>`;
    }).join('');
}

function selectBookingToAttach(bookingId, purpose, autoFillCaption) {
    const found = myConfirmedBookings.find(b => String(b.bookingId) === String(bookingId));
    if (!found) return;
    selectedBookingAsset = found;
    selectedPostPurpose = purpose || 'TIM_DOI';

    const panel = document.getElementById('bookingSelectorPanel');
    if (panel) panel.style.display = 'none';

    const ta = document.getElementById('postContent');
    if (autoFillCaption && ta && !ta.value.trim()) {
        if (selectedPostPurpose === 'PASS_SAN') {
            ta.value = `Mình bận đột xuất nên cần nhượng lại lịch đặt sân đã xác nhận #${found.bookingCode} tại ${found.fieldName} (Sân #${found.courtNumber}) ngày ${found.dateStr} khung giờ ${found.timeStr}. Bạn nào lấy nhắn tin cho mình để mình chuyển quyền sở hữu lịch sân qua tin nhắn luôn nhé!`;
        } else {
            ta.value = `Mình đã đặt sẵn và được xác nhận lịch sân #${found.bookingCode} tại ${found.fieldName} (Sân #${found.courtNumber}) ngày ${found.dateStr} khung giờ ${found.timeStr}. Anh em nào rảnh tham gia giao lưu cùng hội mình nhé!`;
        }
    }

    renderAttachedBookingPreview();
}

function changeAttachedPurpose(purpose) {
    selectedPostPurpose = purpose;
    renderAttachedBookingPreview();
}

function clearAttachedBooking() {
    selectedBookingAsset = null;
    renderAttachedBookingPreview();
}

function renderAttachedBookingPreview() {
    const previewEl = document.getElementById('attachedBookingPreview');
    if (!previewEl) return;

    if (!selectedBookingAsset) {
        previewEl.style.display = 'none';
        previewEl.innerHTML = '';
        return;
    }

    const b = selectedBookingAsset;
    const isPass = selectedPostPurpose === 'PASS_SAN';
    previewEl.style.display = 'block';
    previewEl.innerHTML = `
        <div style="display:flex; align-items:center; justify-content:space-between; gap:8px; flex-wrap:wrap; margin-bottom:10px;">
            <div style="display:flex; align-items:center; gap:8px; flex-wrap:wrap;">
                <span style="background:${isPass ? '#ea580c' : '#15803d'}; color:#fff; font-size:11px; font-weight:800; padding:4px 10px; border-radius:999px;">
                    ${isPass ? '🏷️ ĐÍNH KÈM RAO BÁN / NHƯỢNG LỊCH SÂN' : '🤝 ĐÍNH KÈM RỦ HỘI NHÓM CHƠI CÙNG'}
                </span>
                <button type="button" onclick="changeAttachedPurpose('${isPass ? 'TIM_DOI' : 'PASS_SAN'}')"
                        style="background:#fff; border:1px solid #cbd5e1; border-radius:8px; padding:3px 9px; font-size:11.5px; font-weight:700; cursor:pointer; color:#334155;">
                    🔄 Đổi sang: ${isPass ? '🤝 Rủ hội nhóm' : '🏷️ Rao bán sân'}
                </button>
            </div>
            <button type="button" onclick="clearAttachedBooking()"
                    style="background:#fee2e2; color:#991b1b; border:none; border-radius:8px; padding:4px 10px; font-size:12px; font-weight:700; cursor:pointer;">
                ✕ Bỏ đính kèm
            </button>
        </div>
        <div style="font-size:15px; font-weight:800; color:#0f172a; margin-bottom:4px;">
            🏟️ ${esc(b.fieldName)} — Sân #${b.courtNumber} / ${b.fieldQuantity || 4} (${esc(b.sportType)})
        </div>
        <div style="font-size:12.5px; color:#334155; display:flex; flex-wrap:wrap; gap:12px;">
            <span>🔖 Mã vé: <b>#${esc(b.bookingCode)}</b></span>
            <span>📅 Ngày: <b>${esc(b.dateStr)}</b></span>
            <span>🕒 Giờ: <b>${esc(b.timeStr)}</b></span>
            <span>💰 Giá: <b style="color:#15803d;">${esc(b.priceFormatted)}</b></span>
        </div>`;
}

// ===== CREATE POST =====
async function createPost() {
    const ta = document.getElementById('postContent');
    const btn = document.getElementById('postBtn');
    const content = ta.value.trim();
    if (!content && !selectedBookingAsset) { ta.focus(); return; }

    btn.disabled = true;
    btn.textContent = 'Đang đăng...';

    const params = { action: 'createPost', content };
    if (selectedBookingAsset && selectedBookingAsset.bookingId) {
        params.bookingId = selectedBookingAsset.bookingId;
        params.postPurpose = selectedPostPurpose;
    }

    const body = new URLSearchParams(params);
    const res = await fetch(API, { method: 'POST', body });
    const data = await res.json();

    btn.disabled = false;
    btn.textContent = 'Đăng ngay';

    if (data.status === 'success') {
        ta.value = '';
        clearAttachedBooking();
        loadFeed();
    } else {
        alert('Lỗi: ' + (data.error || 'Không đăng được'));
    }
}

// ===== LOAD FEED =====
async function loadFeed() {
    try {
        const res = await fetch(API + '?action=getPosts');
        const posts = await res.json();

        const feedList = document.getElementById('feedList');
        if (!Array.isArray(posts) || posts.length === 0) {
            feedList.innerHTML = '<div class="feed-empty"><div class="big-icon"><span class="app-icon icon-news" aria-hidden="true"></span></div><p>Chưa có bài đăng nào.<br>Hãy là người đầu tiên chia sẻ!</p></div>';
            return;
        }

        feedList.innerHTML = posts.map(post => renderPost(post)).join('');
    } catch(e) {
        document.getElementById('feedList').innerHTML =
            '<div style="color:red;padding:20px;text-align:center;">Lỗi tải bài viết: ' + e.message + '</div>';
    }
}

function renderAttachedBookingCardInPost(post) {
    if (!post.bookingId || !post.fieldName) return '';
    const isPass = post.postPurpose === 'PASS_SAN';
    const badgeBg = isPass ? '#ea580c' : '#15803d';
    const badgeLabel = isPass ? '🏷️ RAO BÁN / NHƯỢNG LẠI LỊCH SÂN ĐÃ XÁC NHẬN' : '🤝 RỦ HỘI NHÓM / TÌM ĐỒNG ĐỘI CÙNG CHƠI';
    const ownerName = post.bookingOwnerName || post.authorName || 'Thành viên';
    const contactUserId = post.bookingOwnerId || post.userId;

    let actionBtnHtml = '';
    if (Number(contactUserId) === Number(ME_ID)) {
        actionBtnHtml = `
            <a href="${CTX}/chat-friends?transferBookingId=${post.bookingId}"
               style="display:inline-flex; align-items:center; gap:6px; background:#0284c7; color:#fff; text-decoration:none; padding:8px 14px; border-radius:10px; font-size:12.5px; font-weight:700;">
                🔁 Chuyển quyền sở hữu lịch sân này qua Tin nhắn →
            </a>`;
    } else {
        actionBtnHtml = `
            <a href="${CTX}/chat-friends?friendId=${contactUserId}"
               style="display:inline-flex; align-items:center; gap:6px; background:${badgeBg}; color:#fff; text-decoration:none; padding:8px 14px; border-radius:10px; font-size:12.5px; font-weight:700;">
                💬 Nhắn tin liên hệ ${isPass ? 'nhận nhượng sân' : 'tham gia hội nhóm'} ngay →
            </a>`;
    }

    return `
        <div style="margin: 12px 0 6px 0; background:linear-gradient(145deg, #ffffff 0%, #f0fdf4 100%); border:2px solid #86efac; border-radius:14px; padding:15px 18px; box-shadow:0 4px 14px rgba(21,128,61,0.08);">
            <div style="display:flex; align-items:center; justify-content:space-between; gap:8px; flex-wrap:wrap; margin-bottom:10px;">
                <span style="background:${badgeBg}; color:#fff; font-size:11px; font-weight:800; padding:4px 10px; border-radius:999px;">
                    ${badgeLabel}
                </span>
                <span style="background:#dcfce7; color:#166534; font-size:11.5px; font-weight:800; padding:3px 9px; border-radius:8px; border:1px solid #bbf7d0;">
                    💎 Mã tài sản: #${esc(post.bookingCode)} • Đã xác nhận
                </span>
            </div>
            <div style="font-size:16px; font-weight:800; color:#0f172a; margin-bottom:4px;">
                🏟️ ${esc(post.fieldName)} — Sân #${post.courtNumber || 1} / ${post.fieldQuantity || 4} (${esc(post.sportType || '')})
            </div>
            ${post.fieldAddress ? `<div style="font-size:12.5px; color:#475569; margin-bottom:8px;">📍 ${esc(post.fieldAddress)}</div>` : ''}
            <div style="display:flex; flex-wrap:wrap; gap:10px; font-size:13px; color:#1e293b; background:#fff; padding:9px 12px; border-radius:10px; border:1px solid #dcfce7; margin-bottom:12px;">
                <span>📅 Ngày: <b>${esc(post.bookingDate || '')}</b></span>
                <span>•</span>
                <span>🕒 Khung giờ: <b>${esc(post.bookingTime || '')}</b></span>
                <span>•</span>
                <span>💰 Giá thuê: <b style="color:#15803d;">${esc(post.bookingPrice || '')}</b></span>
                <span>•</span>
                <span>👤 Chủ sở hữu hiện tại: <b style="color:#0284c7;">${esc(ownerName)}</b></span>
            </div>
            <div style="display:flex; justify-content:flex-end;">
                ${actionBtnHtml}
            </div>
        </div>`;
}

// ===== RENDER POST =====
function renderPost(post) {
    const initials = post.authorName ? post.authorName[0].toUpperCase() : '?';
    const likedClass = post.likedByMe ? 'liked' : '';
    const heartIcon = '<span class="app-icon icon-heart" aria-hidden="true"></span>';

    const commentsHtml = (post.comments || []).map(c => renderComment(c)).join('');
    const attachedCardHtml = renderAttachedBookingCardInPost(post);

    return '<div class="post-card" id="post-' + post.id + '">' +
        '<div class="post-header">' +
            '<div class="post-avatar">' + esc(initials) + '</div>' +
            '<div>' +
                '<div class="post-author-name">' + esc(post.authorName) + '</div>' +
                '<div class="post-time"><span class="app-icon icon-clock" aria-hidden="true"></span> ' + esc(post.createdAt) + '</div>' +
            '</div>' +
        '</div>' +
        '<div class="post-body">' + esc(post.content) + attachedCardHtml + '</div>' +
        '<div class="post-actions">' +
            '<button class="action-btn ' + likedClass + '" id="like-btn-' + post.id + '" aria-pressed="' + String(Boolean(post.likedByMe)) + '" onclick="toggleLike(' + post.id + ')">' +
                '<span class="heart-icon" id="heart-' + post.id + '">' + heartIcon + '</span>' +
                '<span id="like-count-' + post.id + '">' + post.likeCount + '</span> Thích' +
            '</button>' +
            '<button class="action-btn" onclick="toggleComments(' + post.id + ')">' +
                '<span class="app-icon icon-chat" aria-hidden="true"></span> <span id="cmt-count-' + post.id + '">' + (post.comments ? post.comments.length : 0) + '</span> Bình luận' +
            '</button>' +
        '</div>' +
        '<div class="comments-section hidden" id="comments-' + post.id + '">' +
            '<div id="comment-list-' + post.id + '">' + commentsHtml + '</div>' +
            '<div class="add-comment-row">' +
                '<div class="comment-avatar">' + esc(ME_NAME[0].toUpperCase()) + '</div>' +
                '<input class="comment-input" id="cmt-input-' + post.id + '" ' +
                       'placeholder="Bình luận..." ' +
                       'onkeypress="handleCmtEnter(event,' + post.id + ')">' +
                '<button class="comment-send-btn" aria-label="Gửi bình luận" onclick="addComment(' + post.id + ')"><span class="app-icon icon-send" aria-hidden="true"></span></button>' +
            '</div>' +
        '</div>' +
    '</div>';
}

// ===== RENDER COMMENT =====
function renderComment(c) {
    const initials = c.authorName ? c.authorName[0].toUpperCase() : '?';
    return '<div class="comment-item">' +
            '<div class="comment-avatar">' + esc(initials) + '</div>' +
            '<div class="comment-bubble">' +
                '<div class="comment-author">' + esc(c.authorName) + '</div>' +
                '<div class="comment-text">' + esc(c.content) + '</div>' +
                '<div class="comment-time">' + esc(c.createdAt) + '</div>' +
            '</div>' +
        '</div>';
}

// ===== TOGGLE LIKE =====
async function toggleLike(postId) {
    const btn = document.getElementById('like-btn-' + postId);
    btn.disabled = true;

    const body = new URLSearchParams({ action: 'toggleLike', postId });
    const res = await fetch(API, { method: 'POST', body });
    const data = await res.json();

    btn.disabled = false;

    if (data.likeCount !== undefined) {
        btn.setAttribute("aria-pressed", String(Boolean(data.liked)));
        document.getElementById('like-count-' + postId).textContent = data.likeCount;
        const heartEl = document.getElementById('heart-' + postId);
        if (data.liked) {
            btn.classList.add('liked');
            heartEl.innerHTML = '<span class="app-icon icon-heart" aria-hidden="true"></span>';
            heartEl.classList.remove('heart-icon');
            void heartEl.offsetWidth; // force reflow
            heartEl.classList.add('heart-icon');
        } else {
            btn.classList.remove('liked');
            heartEl.innerHTML = '<span class="app-icon icon-heart" aria-hidden="true"></span>';
        }
    }
}

// ===== TOGGLE COMMENTS SECTION =====
function toggleComments(postId) {
    const section = document.getElementById('comments-' + postId);
    section.classList.toggle('hidden');
    if (!section.classList.contains('hidden')) {
        document.getElementById('cmt-input-' + postId).focus();
    }
}

// ===== ADD COMMENT =====
async function addComment(postId) {
    const input = document.getElementById('cmt-input-' + postId);
    const content = input.value.trim();
    if (!content) return;

    input.value = '';
    input.disabled = true;

    const body = new URLSearchParams({ action: 'addComment', postId, content });
    const res = await fetch(API, { method: 'POST', body });
    const data = await res.json();

    input.disabled = false;
    input.focus();

    if (data.error) { alert(data.error); return; }

    // Append comment to DOM
    const commentList = document.getElementById('comment-list-' + postId);
    commentList.insertAdjacentHTML('beforeend', renderComment(data));

    // Update count
    const countEl = document.getElementById('cmt-count-' + postId);
    countEl.textContent = parseInt(countEl.textContent) + 1;
}

function handleCmtEnter(e, postId) {
    if (e.key === 'Enter' && !e.shiftKey) {
        e.preventDefault();
        addComment(postId);
    }
}

// Enter để đăng bài
document.addEventListener('DOMContentLoaded', function() {
    document.getElementById('postContent').addEventListener('keydown', function(e) {
        if (e.key === 'Enter' && e.ctrlKey) createPost();
    });
    loadFeed();
    loadMyBookingsForAttach(initialShareBookingId);
});
