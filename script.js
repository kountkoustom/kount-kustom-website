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

  // Kount Kustom Supabase connection
  // This is the PUBLIC/anon key only. Never put a service_role key in website code.
  const SUPABASE_URL = "https://syxkowqwqnvyhazgugte.supabase.co";
  const SUPABASE_ANON_KEY = "sb_publishable_7ydS4A0HMSjW0RiR3dL3xg_v13-Nn9F";

  async function saveLead(form) {
    const get = (name) =>
      form.querySelector(`[name="${name}"]`)?.value?.trim() || "";

    const name = get("name");
    const mobile = get("mobile") || get("phone");
    const company = get("company");
    const email = get("email");
    const city = get("city");
    const leadType =
      get("lead_type") ||
      get("type") ||
      get("enquiry_type") ||
      "Website Enquiry";
    const requirement = get("requirement") || get("message");

    const lead = {
      lead_type: leadType,
      name: name,
      company: company,
      mobile: mobile,
      email: email,
      city: city,
      requirement: requirement,
      status: "new"
    };

    // Remove empty optional values. This keeps the insert compatible
    // with the existing public.leads table.
    Object.keys(lead).forEach((key) => {
      if (lead[key] === "") delete lead[key];
    });

    const response = await fetch(`${SUPABASE_URL}/rest/v1/leads`, {
      method: "POST",
      headers: {
        "apikey": SUPABASE_ANON_KEY,
        "Authorization": `Bearer ${SUPABASE_ANON_KEY}`,
        "Content-Type": "application/json",
        "Prefer": "return=minimal"
      },
      body: JSON.stringify(lead)
    });

    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(errorText || `Supabase error ${response.status}`);
    }
  }

  document.querySelectorAll("form.lead-form").forEach(form => {
    form.addEventListener("submit", async (event) => {
      event.preventDefault();

      const name = form.querySelector('[name="name"]')?.value?.trim() || "there";
      let message = form.querySelector(".form-message");

      if (!message) {
        message = document.createElement("div");
        message.className = "form-message";
        form.appendChild(message);
      }

      const button = form.querySelector('button[type="submit"], input[type="submit"]');
      if (button) button.disabled = true;

      message.textContent = "Submitting your enquiry...";

      try {
        await saveLead(form);

        message.textContent =
          `Thank you ${name}. Your enquiry has been submitted successfully. ` +
          `Our team will contact you shortly.`;
        message.setAttribute("role", "status");
        form.reset();
      } catch (error) {
        console.error("Kount Kustom lead submission failed:", error);
        message.textContent =
          "Sorry, we could not submit your enquiry right now. Please try again or contact us directly.";
        message.setAttribute("role", "alert");
      } finally {
        if (button) button.disabled = false;
      }
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
