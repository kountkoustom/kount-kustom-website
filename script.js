(function () {
  const toggle = document.querySelector(".menu-toggle");
  const nav = document.querySelector(".main-nav");

  if (toggle && nav) {
    toggle.addEventListener("click", () => {
      const open = nav.classList.toggle("open");
      toggle.setAttribute("aria-expanded", String(open));
    });
    nav.querySelectorAll("a").forEach(a =>
      a.addEventListener("click", () => nav.classList.remove("open"))
    );
  }

  document.querySelectorAll("form.lead-form").forEach(form => {
    form.addEventListener("submit", (event) => {
      event.preventDefault();
      const name = form.querySelector('[name="name"]')?.value || "there";
      let message = form.querySelector(".form-message");
      if (!message) {
        message = document.createElement("div");
        message.className = "form-message";
        form.appendChild(message);
      }
      message.textContent =
        `Thank you ${name}. Your enquiry has been captured in this website prototype. ` +
        `The next deployment stage will connect this form to the Kount Kustom lead database.`;
      message.setAttribute("role", "status");
      form.reset();
    });
  });

  const solutionCards = document.getElementById("solutionCards");
  if (solutionCards) {
    const solutions = [
      ["📹","Video Security","CCTV, AI cameras, analytics, ANPR and intelligent detection."],
      ["🔥","Fire & Life Safety","Fire alarm, PA/VA and emergency communication."],
      ["🔐","Access Security","Access control, door interlocking and visitor management."],
      ["🚨","Emergency Response","Hooter, flash light, auto dialer and alerts."],
      ["🧠","Security Integration","AI, edge automation and response logic."]
    ];
    solutionCards.innerHTML = solutions.map(x =>
      `<article class="solution-card"><div class="icon">${x[0]}</div><h3>${x[1]}</h3><p>${x[2]}</p></article>`
    ).join("");
  }
})();