function timeToMinutes(t) {
    if (!t || !t.includes(':')) return 0;
    const parts = t.split(':').map(Number);
    return parts[0] * 60 + parts[1];
}

function minutesToTime(m) {
    const hh = String(Math.floor(m / 60)).padStart(2, '0');
    const mm = String(m % 60).padStart(2, '0');
    return hh + ':' + mm;
}

function getOverlappingBookings(dateStr, startMin, endMin) {
    return existingBookings.filter(b => {
        if (b.date !== dateStr) return false;
        const bStart = timeToMinutes(b.start);
        const bEnd = timeToMinutes(b.end);
        return bStart < endMin && bEnd > startMin;
    });
}

function getPeakBookedCount(dateStr, startMin, endMin) {
    const overlaps = getOverlappingBookings(dateStr, startMin, endMin);
    if (overlaps.length === 0) return 0;
    let maxCount = overlaps.length;
    for (let t = startMin; t < endMin; t += 30) {
        const stepEnd = Math.min(t + 30, endMin);
        let stepCount = 0;
        overlaps.forEach(b => {
            if (timeToMinutes(b.start) < stepEnd && timeToMinutes(b.end) > t) {
                stepCount++;
            }
        });
        if (stepCount > maxCount) maxCount = stepCount;
    }
    return maxCount;
}

function getUsedCourtMap(dateStr, startMin, endMin) {
    const overlaps = getOverlappingBookings(dateStr, startMin, endMin);
    const usedMap = {};
    overlaps.forEach(b => {
        let c = b.courtNumber || 1;
        if (c >= 1 && c <= currentFieldQuantity && !usedMap[c]) {
            usedMap[c] = b;
        } else {
            for (let fallback = 1; fallback <= currentFieldQuantity; fallback++) {
                if (!usedMap[fallback]) {
                    usedMap[fallback] = b;
                    break;
                }
            }
        }
    });
    return usedMap;
}

function renderTimeSlotGrid() {
    const grid = document.getElementById('timeSlotGrid');
    const dateStr = document.getElementById('bookingDate').value;
    const selectedStartMin = timeToMinutes(document.getElementById('bookingStartTime').value);
    const selectedEndMin = timeToMinutes(document.getElementById('bookingEndTime').value);

    const openMin = timeToMinutes(currentFieldOpen);
    const closeMin = timeToMinutes(currentFieldClose);

    const now = new Date();
    const todayIso = now.getFullYear() + '-' + String(now.getMonth() + 1).padStart(2, '0') + '-' + String(now.getDate()).padStart(2, '0');
    const nowMin = now.getHours() * 60 + now.getMinutes();

    let html = '';
    for (let m = openMin; m + 60 <= closeMin; m += 60) {
        const slotStart = m;
        const slotEnd = m + 60;
        const startLabel = minutesToTime(slotStart);
        const endLabel = minutesToTime(slotEnd);

        const overlaps = getOverlappingBookings(dateStr, slotStart, slotEnd);
        const bookedCount = Math.min(currentFieldQuantity, overlaps.length);
        const remaining = Math.max(0, currentFieldQuantity - bookedCount);
        const isFull = overlaps.length >= currentFieldQuantity;
        const isPast = (dateStr === todayIso && slotStart <= nowMin);
        const isSelected = (selectedStartMin <= slotStart && selectedEndMin >= slotEnd && selectedEndMin > selectedStartMin);

        let stateClass = 'slot-available';
        let statusLabel = 'Còn ' + remaining + '/' + currentFieldQuantity + ' sân';
        let barColor = '#22c55e';

        if (isPast) {
            stateClass = 'slot-past';
            statusLabel = 'Đã qua giờ';
            barColor = '#94a3b8';
        } else if (isFull) {
            stateClass = 'slot-full';
            statusLabel = 'Đủ ' + currentFieldQuantity + '/' + currentFieldQuantity + ' (Hết)';
            barColor = '#ef4444';
        } else if (bookedCount > 0) {
            stateClass = 'slot-partial';
            statusLabel = 'Đã đặt ' + bookedCount + '/' + currentFieldQuantity + ' • Còn ' + remaining;
            barColor = '#f59e0b';
        }

        if (isSelected && !isFull && !isPast) {
            stateClass += ' slot-selected';
        }

        const pct = Math.min(100, Math.round((bookedCount / currentFieldQuantity) * 100));
        const disabledAttr = (isFull || isPast) ? 'disabled' : '';

        html += '<button type="button" class="slot-btn ' + stateClass + '" ' + disabledAttr +
                ' onclick="selectSlotFromGrid(\'' + startLabel + '\', \'' + endLabel + '\')">' +
                '<div class="slot-time-text">' + startLabel + ' - ' + endLabel + '</div>' +
                '<div class="slot-cap-text"><span>' + statusLabel + '</span></div>' +
                '<div class="slot-bar"><div class="slot-bar-fill" style="width:' + pct + '%; background:' + barColor + ';"></div></div>' +
                '</button>';
    }
    grid.innerHTML = html;
}

function selectSlotFromGrid(startStr, endStr) {
    document.getElementById('bookingStartTime').value = startStr;
    document.getElementById('bookingEndTime').value = endStr;
    onDateOrTimeChange();
}

function quickPickSlot(dateStr, startStr, endStr) {
    document.getElementById('bookingDate').value = dateStr;
    document.getElementById('bookingStartTime').value = startStr;
    document.getElementById('bookingEndTime').value = endStr;
    onDateOrTimeChange();
    document.getElementById('bookingForm').scrollIntoView({ behavior: 'smooth', block: 'start' });
}

function selectCourtNumber(courtNo) {
    const hiddenInput = document.getElementById('selectedCourtNumber');
    hiddenInput.value = courtNo ? String(courtNo) : '';
    renderCourtSelectorAndValidate();
}

function renderCourtSelectorAndValidate() {
    const dateStr = document.getElementById('bookingDate').value;
    const startVal = document.getElementById('bookingStartTime').value;
    const endVal = document.getElementById('bookingEndTime').value;
    const startMin = timeToMinutes(startVal);
    const endMin = timeToMinutes(endVal);

    const courtGrid = document.getElementById('courtProductGrid');
    const hiddenCourt = document.getElementById('selectedCourtNumber');
    const conflictBanner = document.getElementById('slotConflictBanner');
    const summaryBanner = document.getElementById('slotStatusSummary');
    const statusText = document.getElementById('slotStatusText');
    const remainingBadge = document.getElementById('slotRemainingBadge');
    const submitBtn = document.getElementById('btnSubmitBooking');

    if (endMin <= startMin) {
        courtGrid.innerHTML = '<div style="grid-column: 1/-1; font-size: 12.5px; color: #dc2626;">Vui lòng chọn giờ kết thúc sau giờ bắt đầu.</div>';
        submitBtn.disabled = true;
        submitBtn.querySelector('.booking-submit-label').textContent = 'Khung giờ chưa hợp lệ';
        return;
    }

    const usedMap = getUsedCourtMap(dateStr, startMin, endMin);
    const usedCount = Object.keys(usedMap).length;
    const peakCount = getPeakBookedCount(dateStr, startMin, endMin);
    const effectiveBooked = Math.min(currentFieldQuantity, Math.max(usedCount, peakCount));
    const remaining = Math.max(0, currentFieldQuantity - effectiveBooked);
    const isAllFull = effectiveBooked >= currentFieldQuantity;

    // Nếu sân đang chọn bị trùng với đơn đã đặt thì tự động chuyển sang sân trống đầu tiên
    let currentSelected = parseInt(hiddenCourt.value, 10);
    if (isNaN(currentSelected) || currentSelected < 1 || currentSelected > currentFieldQuantity || usedMap[currentSelected]) {
        currentSelected = 0;
        for (let c = 1; c <= currentFieldQuantity; c++) {
            if (!usedMap[c]) {
                currentSelected = c;
                break;
            }
        }
        hiddenCourt.value = currentSelected > 0 ? String(currentSelected) : '';
    }

    let courtHtml = '';
    for (let c = 1; c <= currentFieldQuantity; c++) {
        const bookedOrder = usedMap[c];
        const isBusy = Boolean(bookedOrder) || isAllFull;
        const isSelected = (!isBusy && currentSelected === c);
        if (isBusy) {
            const who = bookedOrder ? bookedOrder.customerName : 'Đã kín';
            courtHtml += '<button type="button" class="court-card-btn" disabled>' +
                    '<strong><span class="app-icon icon-lock" aria-hidden="true"></span> Sân #' + c + '</strong>' +
                    '<span style="color:#dc2626;">Đã đặt (' + who + ')</span>' +
                    '</button>';
        } else {
            courtHtml += '<button type="button" class="court-card-btn ' + (isSelected ? 'active' : '') + '" onclick="selectCourtNumber(' + c + ')">' +
                    '<strong>' + (isSelected ? '<span class="app-icon icon-check" aria-hidden="true"></span> ' : '<span class="app-icon icon-court" aria-hidden="true"></span> ') + 'Sân #' + c + '</strong>' +
                    '<span style="color:#15803d;">' + (isSelected ? 'Đang chọn đặt' : 'Còn trống • Bấm chọn') + '</span>' +
                    '</button>';
        }
    }
    courtGrid.innerHTML = courtHtml;

    if (isAllFull) {
        conflictBanner.style.display = 'block';
        summaryBanner.style.display = 'none';
        submitBtn.disabled = true;
        submitBtn.querySelector('.booking-submit-label').textContent = 'Đã đủ ' + currentFieldQuantity + '/' + currentFieldQuantity + ' đơn - Không thể bấm đặt sân';
    } else {
        conflictBanner.style.display = 'none';
        summaryBanner.style.display = 'flex';
        statusText.innerHTML = 'Khung giờ <strong>' + startVal + ' - ' + endVal + '</strong> ngày <strong>' + dateStr + '</strong>: đã có <strong>' + effectiveBooked + '/' + currentFieldQuantity + '</strong> đơn đặt.';
        remainingBadge.innerText = 'Còn ' + remaining + '/' + currentFieldQuantity + ' ' + productUnitName + ' trống';
        submitBtn.disabled = false;
        submitBtn.querySelector('.booking-submit-label').textContent = 'Xác nhận đặt Sân #' + (currentSelected || 1) + ' (' + startVal + ' - ' + endVal + ')';
    }
}

function calculateEstimate() {
    const startVal = document.getElementById('bookingStartTime').value;
    const endVal = document.getElementById('bookingEndTime').value;
    if (!startVal || !endVal) return;

    const startMinutes = timeToMinutes(startVal);
    const endMinutes = timeToMinutes(endVal);

    const diffMinutes = endMinutes - startMinutes;
    const durTextEl = document.getElementById('calcDurationText');
    const priceTextEl = document.getElementById('calcPriceText');

    if (diffMinutes <= 0) {
        durTextEl.innerText = 'Giờ kết thúc phải sau giờ bắt đầu';
        priceTextEl.innerText = '0 đ';
        return;
    }

    const hours = diffMinutes / 60;
    const total = Math.round(hours * currentFieldPrice);
    durTextEl.innerText = 'Thời lượng: ' + hours.toFixed(1) + ' giờ';
    priceTextEl.innerText = total.toLocaleString('vi-VN') + ' đ';
}

function onManualTimeInput() {
    calculateEstimate();
    renderTimeSlotGrid();
    renderCourtSelectorAndValidate();
}

function onDateOrTimeChange() {
    calculateEstimate();
    renderTimeSlotGrid();
    renderCourtSelectorAndValidate();
}

function validateBookingForm() {
    const dateStr = document.getElementById('bookingDate').value;
    const startVal = document.getElementById('bookingStartTime').value;
    const endVal = document.getElementById('bookingEndTime').value;
    if (!startVal || !endVal) {
        alert('Vui lòng chọn giờ bắt đầu và giờ kết thúc.');
        return false;
    }

    const startMinutes = timeToMinutes(startVal);
    const endMinutes = timeToMinutes(endVal);

    if (endMinutes <= startMinutes) {
        alert('Giờ kết thúc phải sau giờ bắt đầu.');
        return false;
    }

    const openMinutes = timeToMinutes(currentFieldOpen);
    const closeMinutes = timeToMinutes(currentFieldClose);

    if (startMinutes < openMinutes || endMinutes > closeMinutes) {
        alert('Khung giờ đặt phải nằm trong giờ mở cửa của sân (' + currentFieldOpen + ' - ' + currentFieldClose + ').');
        return false;
    }

    const usedMap = getUsedCourtMap(dateStr, startMinutes, endMinutes);
    const peakCount = getPeakBookedCount(dateStr, startMinutes, endMinutes);
    if (Object.keys(usedMap).length >= currentFieldQuantity || peakCount >= currentFieldQuantity) {
        alert('Khung giờ này đã nhận đủ ' + currentFieldQuantity + '/' + currentFieldQuantity + ' đơn đặt sân. Không thể đặt thêm!');
        return false;
    }

    return true;
}

// Khởi tạo bảng chọn khung giờ & bảng chọn sản phẩm ngay khi tải trang
onDateOrTimeChange();
