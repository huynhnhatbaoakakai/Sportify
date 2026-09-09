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

function filterServices(keyword) {
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

    const queryLabels = {
    venue: "thuê sân/phòng tập",
    clothing: "thuê quần áo",
    gear: "thuê gear",
    pt: "thuê PT"
};

    const displayQuery = queryLabels[query] || query;

    resultMessage.textContent =
        `Tìm thấy ${visibleCount} dịch vụ cho "${displayQuery}".`;

        emptyState.hidden = visibleCount !== 0;

        document.querySelector("#featured").scrollIntoView({
            behavior: "smooth"
        });
    }

searchForm.addEventListener("submit", (event) => {
    event.preventDefault();
    filterServices(searchInput.value);
});

filterButtons.forEach((button) => {
    button.addEventListener("click", () => {
        const keyword = button.dataset.query;
        searchInput.value = keyword;
        filterServices(keyword);
    });
});

clearFilterButton.addEventListener("click", () => {
    searchInput.value = "";
    filterServices("");
});