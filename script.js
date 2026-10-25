// ==========================================================================
// PORTFOLIO GUILLAUME AHISSOU · LOGIQUE INTERACTIVE
// ==========================================================================

var GOOGLE_DRIVE_SPOTS_URL = "https://drive.google.com/drive/folders/1JD6zOxRPnUjNzrgF9iiRDZh6wNJbTav7?usp=sharing";

document.addEventListener("DOMContentLoaded", function () {
  // 1. Boutons menant aux spots publicitaires Google Drive
  document.querySelectorAll("[data-drive-spots]").forEach(function (btn) {
    btn.setAttribute("href", GOOGLE_DRIVE_SPOTS_URL);
    btn.setAttribute("target", "_blank");
    btn.setAttribute("rel", "noopener");
  });

  // 2. Initialisation de la galerie visuelle
  if (typeof REALISATIONS_DATA !== "undefined" && Array.isArray(REALISATIONS_DATA)) {
    initGallery(REALISATIONS_DATA);
  }
});

function initGallery(items) {
  var galleryGrid = document.getElementById("gallery-grid");
  var loadMoreBtn = document.getElementById("btn-load-more");
  var filterButtons = document.querySelectorAll(".filter-btn");
  var countBadge = document.getElementById("gallery-count-badge");

  if (!galleryGrid) return;

  var currentCategory = "all";
  var itemsPerPage = 12;
  var displayedCount = itemsPerPage;
  var filteredItems = items;

  // Filtrage
  function applyFilter(category) {
    currentCategory = category;
    displayedCount = itemsPerPage;

    if (category === "all") {
      filteredItems = items;
    } else {
      filteredItems = items.filter(function (it) {
        return it.category === category;
      });
    }

    if (countBadge) {
      countBadge.textContent = filteredItems.length + " visuel" + (filteredItems.length > 1 ? "s" : "");
    }

    renderItems();
  }

  // Rendu des cartes visuelles
  function renderItems() {
    galleryGrid.innerHTML = "";
    var toShow = filteredItems.slice(0, displayedCount);

    toShow.forEach(function (item, index) {
      var card = document.createElement("div");
      card.className = "visuel-card";
      card.setAttribute("data-index", index);

      card.innerHTML =
        '<div class="visuel-img-box">' +
          '<img src="' + item.file + '" alt="' + item.title + '" loading="lazy" />' +
          '<span class="visuel-badge">' + item.categoryName + '</span>' +
        '</div>' +
        '<div class="visuel-info">' +
          '<h4>' + item.title + '</h4>' +
          '<span class="visuel-action">Agrandir en HD ↗</span>' +
        '</div>';

      card.addEventListener("click", function () {
        openLightbox(filteredItems, index);
      });

      galleryGrid.appendChild(card);
    });

    // Gestion du bouton "Charger plus"
    if (loadMoreBtn) {
      if (displayedCount >= filteredItems.length) {
        loadMoreBtn.style.display = "none";
      } else {
        loadMoreBtn.style.display = "inline-flex";
        var remaining = filteredItems.length - displayedCount;
        loadMoreBtn.textContent = "Afficher plus de visuels (" + remaining + " restants) ↓";
      }
    }
  }

  // Événements boutons de filtre
  filterButtons.forEach(function (btn) {
    btn.addEventListener("click", function () {
      filterButtons.forEach(function (b) { b.classList.remove("active"); });
      btn.classList.add("active");
      var cat = btn.getAttribute("data-category") || "all";
      applyFilter(cat);
    });
  });

  // Bouton "Charger plus"
  if (loadMoreBtn) {
    loadMoreBtn.addEventListener("click", function () {
      displayedCount += itemsPerPage;
      renderItems();
    });
  }

  // Premier rendu
  applyFilter("all");
}

// ==========================================================================
// LIGHTBOX / ZOOM PLEIN ÉCRAN
// ==========================================================================
var activeList = [];
var activeIndex = 0;

function openLightbox(list, index) {
  activeList = list;
  activeIndex = index;

  var lightbox = document.getElementById("lightbox");
  if (!lightbox) return;

  updateLightboxContent();
  lightbox.classList.add("active");
  document.body.style.overflow = "hidden";
}

function closeLightbox() {
  var lightbox = document.getElementById("lightbox");
  if (!lightbox) return;

  lightbox.classList.remove("active");
  document.body.style.overflow = "";
}

function updateLightboxContent() {
  if (!activeList.length) return;
  var item = activeList[activeIndex];

  var img = document.getElementById("lightbox-img");
  var title = document.getElementById("lightbox-title");
  var cat = document.getElementById("lightbox-category");

  if (img) {
    img.src = item.file;
    img.alt = item.title;
  }
  if (title) {
    title.textContent = item.title;
  }
  if (cat) {
    cat.textContent = item.categoryName + " · " + (activeIndex + 1) + " / " + activeList.length;
  }
}

function nextLightbox() {
  if (!activeList.length) return;
  activeIndex = (activeIndex + 1) % activeList.length;
  updateLightboxContent();
}

function prevLightbox() {
  if (!activeList.length) return;
  activeIndex = (activeIndex - 1 + activeList.length) % activeList.length;
  updateLightboxContent();
}

// Initialisation des écouteurs pour la lightbox
document.addEventListener("DOMContentLoaded", function () {
  var lightbox = document.getElementById("lightbox");
  var closeBtn = document.getElementById("lightbox-close");
  var nextBtn = document.getElementById("lightbox-next");
  var prevBtn = document.getElementById("lightbox-prev");

  if (closeBtn) closeBtn.addEventListener("click", closeLightbox);
  if (nextBtn) nextBtn.addEventListener("click", nextLightbox);
  if (prevBtn) prevBtn.addEventListener("click", prevLightbox);

  if (lightbox) {
    lightbox.addEventListener("click", function (e) {
      if (e.target === lightbox || e.target.classList.contains("lightbox-img-wrapper")) {
        closeLightbox();
      }
    });
  }

  document.addEventListener("keydown", function (e) {
    if (!lightbox || !lightbox.classList.contains("active")) return;
    if (e.key === "Escape") closeLightbox();
    if (e.key === "ArrowRight") nextLightbox();
    if (e.key === "ArrowLeft") prevLightbox();
  });
});
