window.SportifyAvailability = (() => {
    const labels = {FREE: 'Còn trống', BOOKED: 'Đã đặt', BLOCKED: 'Đã khóa', PAST: 'Đã qua giờ', INACTIVE: 'Tạm ngưng'};
    async function load(context, fieldId, date, signal) {
        const query = new URLSearchParams({fieldId, date});
        const response = await fetch(context + '/availability-api?' + query, {cache: 'no-store', signal});
        if (response.status === 401 || response.redirected) throw new Error('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
        const day = await response.json();
        if (!response.ok) throw new Error(day.error || 'Không thể tải lịch trống.');
        return day;
    }
    function render(container, day, onSelect) {
        container.replaceChildren();
        if (!day.windows.length) { container.textContent = 'Không có khung giờ hoạt động trong ngày này.'; return; }
        day.windows.forEach(window => {
            const element = document.createElement(window.status === 'FREE' && onSelect ? 'button' : 'div');
            if (element.tagName === 'BUTTON') {
                element.type = 'button';
                element.addEventListener('click', () => onSelect(window));
            }
            element.className = 'availability-window slot-' + window.status.toLowerCase();
            const time = document.createElement('strong');
            time.textContent = window.startsAt.slice(11, 16) + ' – ' + window.endsAt.slice(11, 16);
            const status = document.createElement('span');
            status.textContent = labels[window.status] || window.status;
            const reason = document.createElement('small');
            reason.textContent = window.reason;
            element.append(time, status, reason);
            container.appendChild(element);
        });
    }
    return {load, render};
})();
