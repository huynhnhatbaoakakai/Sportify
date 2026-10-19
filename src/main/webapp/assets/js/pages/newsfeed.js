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

function feedIcon(name) {
    return `<span class="app-icon icon-${name}" aria-hidden="true"></span>`;
}

function sportLabel(type) {
    return ({ PICKLEBALL: 'Pickleball', TABLE_TENNIS: 'Bóng bàn', BASKETBALL: 'Bóng rổ',
        GYM: 'Phòng Gym', SWIMMING: 'Bơi lội', FOOTBALL: 'Bóng đá' })[type] || type || 'Thể thao';
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
            <div class="booking-selector-empty">
                ${feedIcon('inbox')} Bạn chưa có lịch đặt sân đã xác nhận để đính kèm.<br>
                <a href="${CTX}/home#fields">Đặt sân tại Trang chủ ${feedIcon('arrow')}</a>
            </div>`;
        return;
    }

    listEl.innerHTML = myConfirmedBookings.map(b => {
        const isSelected = selectedBookingAsset && String(selectedBookingAsset.bookingId) === String(b.bookingId);
        return `
            <div class="booking-selector-item${isSelected ? ' is-selected' : ''}">
                <div>
                    <div class="booking-selector-title">
                        ${feedIcon('court')} ${esc(b.fieldName)} · Sân #${esc(b.courtNumber || 1)}
                        <span class="booking-code">#${esc(b.bookingCode)}</span>
                    </div>
                    <div class="booking-selector-meta">
                        <span>${feedIcon('calendar')} ${esc(b.dateStr)}</span>
                        <span>${feedIcon('clock')} ${esc(b.timeStr)}</span>
                        <span>${feedIcon('wallet')} ${esc(b.priceFormatted)}</span>
                    </div>
                </div>
                <div class="booking-selector-actions">
                    <button type="button" class="booking-small-btn" onclick="selectBookingToAttach(${Number(b.bookingId)}, 'TIM_DOI', true)">
                        ${feedIcon('users')} Rủ hội nhóm
                    </button>
                    <button type="button" class="booking-small-btn" onclick="selectBookingToAttach(${Number(b.bookingId)}, 'PASS_SAN', true)">
                        ${feedIcon('refresh')} Nhượng lịch sân
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
        <div class="booking-attachment-header">
            <span class="booking-purpose${isPass ? ' purpose-transfer' : ''}">
                ${feedIcon(isPass ? 'refresh' : 'users')} ${isPass ? 'Nhượng lịch sân' : 'Rủ hội nhóm'}
            </span>
            <button type="button" class="booking-small-btn booking-remove" onclick="clearAttachedBooking()">
                ${feedIcon('close')} Bỏ đính kèm
            </button>
        </div>
        <div class="booking-attachment-title">${feedIcon('court')} ${esc(b.fieldName)}</div>
        <div class="booking-attachment-subtitle">Sân #${esc(b.courtNumber || 1)} / ${esc(b.fieldQuantity || 1)} · ${esc(sportLabel(b.sportType))} · #${esc(b.bookingCode)}</div>
        <div class="booking-selector-meta">
            <span>${feedIcon('calendar')} ${esc(b.dateStr)}</span>
            <span>${feedIcon('clock')} ${esc(b.timeStr)}</span>
            <span>${feedIcon('wallet')} ${esc(b.priceFormatted)}</span>
        </div>
        <button type="button" class="booking-small-btn booking-purpose-switch" onclick="changeAttachedPurpose('${isPass ? 'TIM_DOI' : 'PASS_SAN'}')">
            ${feedIcon('refresh')} Đổi sang ${isPass ? 'rủ hội nhóm' : 'nhượng lịch sân'}
        </button>`;
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
            '<div class="feed-empty">Không thể tải bài viết. Vui lòng thử lại.</div>';
    }
}

function renderAttachedBookingCardInPost(post) {
    if (!post.bookingId || !post.fieldName) return '';
    const isPass = post.postPurpose === 'PASS_SAN';
    const ownerName = post.bookingOwnerName || post.authorName || 'Thành viên';
    const contactUserId = post.bookingOwnerId || post.userId;
    const isOwner = Number(contactUserId) === Number(ME_ID);
    const actionUrl = isOwner ? `transferBookingId=${Number(post.bookingId)}` : `friendId=${Number(contactUserId)}`;
    const statusLabel = ({CONFIRMED: 'Đã xác nhận', COMPLETED: 'Đã hoàn thành',
        CANCELLED: 'Đã hủy', REJECTED: 'Đã từ chối', PENDING: 'Chờ xác nhận'})[post.bookingStatus];

    return `
        <article class="booking-attachment${isPass ? ' is-transfer' : ''}">
            <div class="booking-attachment-header">
                <span class="booking-purpose${isPass ? ' purpose-transfer' : ''}">
                    ${feedIcon(isPass ? 'refresh' : 'users')} ${isPass ? 'Nhượng lịch sân' : 'Rủ hội nhóm'}
                </span>
                <span class="booking-code">#${esc(post.bookingCode)}</span>
            </div>
            <h2 class="booking-attachment-title">${feedIcon('court')} ${esc(post.fieldName)}</h2>
            <div class="booking-attachment-subtitle">Sân #${esc(post.courtNumber || 1)} / ${esc(post.fieldQuantity || 1)} · ${esc(sportLabel(post.sportType))}</div>
            ${statusLabel ? `<div class="booking-attachment-status">${feedIcon('info')} ${statusLabel}</div>` : ''}
            ${post.fieldAddress ? `<div class="booking-attachment-address">${feedIcon('pin')} <span>${esc(post.fieldAddress)}</span></div>` : ''}
            <dl class="booking-attachment-details">
                <div><dt>${feedIcon('calendar')} Ngày đặt</dt><dd>${esc(post.bookingDate)}</dd></div>
                <div><dt>${feedIcon('clock')} Khung giờ</dt><dd>${esc(post.bookingTime)}</dd></div>
                <div><dt>${feedIcon('wallet')} Giá thuê</dt><dd class="booking-price">${esc(post.bookingPrice)}</dd></div>
                <div><dt>${feedIcon('user')} Người sở hữu</dt><dd>${esc(ownerName)}</dd></div>
            </dl>
            <div class="booking-attachment-footer">
                <a class="booking-contact-btn" href="${CTX}/chat-friends?${actionUrl}">
                    ${feedIcon(isOwner ? 'refresh' : 'chat')} ${isOwner ? 'Chuyển lịch qua tin nhắn' : 'Nhắn tin liên hệ'} ${feedIcon('arrow')}
                </a>
            </div>
        </article>`;
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
        '<div class="post-body">' + (post.content ? '<div class="post-text">' + esc(post.content) + '</div>' : '') + attachedCardHtml + '</div>' +
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
