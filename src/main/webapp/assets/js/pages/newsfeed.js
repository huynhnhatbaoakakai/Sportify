const API = CTX + '/newsfeed-api';

// ===== ESCAPE HTML =====
function esc(str) {
    if (!str) return '';
    return String(str)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;');
}

// ===== CREATE POST =====
async function createPost() {
    const ta = document.getElementById('postContent');
    const btn = document.getElementById('postBtn');
    const content = ta.value.trim();
    if (!content) { ta.focus(); return; }

    btn.disabled = true;
    btn.textContent = 'Đang đăng...';

    const body = new URLSearchParams({ action: 'createPost', content });
    const res = await fetch(API, { method: 'POST', body });
    const data = await res.json();

    btn.disabled = false;
    btn.textContent = 'Đăng ngay';

    if (data.status === 'success') {
        ta.value = '';
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

// ===== RENDER POST =====
function renderPost(post) {
    const initials = post.authorName ? post.authorName[0].toUpperCase() : '?';
    const likedClass = post.likedByMe ? 'liked' : '';
    const heartIcon = '<span class="app-icon icon-heart" aria-hidden="true"></span>';

    const commentsHtml = (post.comments || []).map(c => renderComment(c)).join('');

    return '<div class="post-card" id="post-' + post.id + '">' +
        '<div class="post-header">' +
            '<div class="post-avatar">' + esc(initials) + '</div>' +
            '<div>' +
                '<div class="post-author-name">' + esc(post.authorName) + '</div>' +
                '<div class="post-time"><span class="app-icon icon-clock" aria-hidden="true"></span> ' + esc(post.createdAt) + '</div>' +
            '</div>' +
        '</div>' +
        '<div class="post-body">' + esc(post.content) + '</div>' +
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
});
