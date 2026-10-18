const searchForm = document.querySelector("#searchForm");
const searchInput = document.querySelector("#searchInput");
const serviceCards = document.querySelectorAll(".service-card");
const filterButtons = document.querySelectorAll(".filter-button");
const clearFilterButton = document.querySelector("#clearFilter");
const resultMessage = document.querySelector("#resultMessage");
const emptyState = document.querySelector("#emptyState");

function normalizeText(text) {
    return text
        .toLowerCase()
        .normalize("NFD")
        .replace(/[\u0300-\u036f]/g, "")
        .replace(/đ/g, "d");
}

function filterCourts(keyword) {
    const normalizedKeyword = normalizeText(keyword.trim());
    let visibleCount = 0;

    serviceCards.forEach((card) => {
        const searchableText = normalizeText(card.dataset.search);
        const isVisible = searchableText.includes(normalizedKeyword);

        card.hidden = !isVisible;

        if (isVisible) {
            visibleCount++;
        }
    });

    resultMessage.textContent = keyword.trim()
        ? `Tìm thấy ${visibleCount} nhóm sân cho "${keyword}".`
        : "Đang hiển thị tất cả nhóm sân.";

    emptyState.hidden = visibleCount !== 0;

    document.querySelector("#featured").scrollIntoView({
        behavior: "smooth"
    });
}

searchForm.addEventListener("submit", (event) => {
    event.preventDefault();
    filterCourts(searchInput.value);
});

filterButtons.forEach((button) => {
    button.addEventListener("click", () => {
        const keyword = button.dataset.query;
        searchInput.value = keyword;
        filterCourts(keyword);
    });
});

clearFilterButton.addEventListener("click", () => {
    searchInput.value = "";
    filterCourts("");
});
