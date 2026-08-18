const nav = document.getElementById("nav");
const menuBtn = document.querySelector(".menu-btn");

if (menuBtn && nav) {
  menuBtn.addEventListener("click", () => {
    const open = nav.classList.toggle("is-open");
    menuBtn.setAttribute("aria-expanded", String(open));
    menuBtn.textContent = open ? "Cerrar" : "Menú";
  });

  nav.querySelectorAll("a").forEach((link) => {
    link.addEventListener("click", () => {
      nav.classList.remove("is-open");
      menuBtn.setAttribute("aria-expanded", "false");
      menuBtn.textContent = "Menú";
    });
  });
}

const itinerary = document.getElementById("itinerary");
const tabs = document.querySelectorAll(".tab");

function applyView(view) {
  if (!itinerary) return;
  itinerary.querySelectorAll("article").forEach((row) => {
    const who = row.getAttribute("data-who") || "";
    const show =
      view === "plan" ||
      who === "all" ||
      who.split(/\s+/).includes(view);
    row.classList.toggle("is-off", !show);
  });
}

tabs.forEach((tab) => {
  tab.addEventListener("click", () => {
    tabs.forEach((t) => {
      t.classList.toggle("is-on", t === tab);
      t.setAttribute("aria-selected", t === tab ? "true" : "false");
    });
    applyView(tab.dataset.view);
  });
});

applyView("plan");
