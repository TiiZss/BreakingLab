const labsEl = document.querySelector("#labs");
const countEl = document.querySelector("#count");
const noteEl = document.querySelector("#note");
const dialog = document.querySelector("#confirm");
const confirmText = document.querySelector("#confirm-text");
const marks = new Map();
const logs = new Map();
let currentLabs = [];

function wantsPublic(lab) {
  if (lab.running) return Boolean(lab.public);
  return marks.get(lab.name) === true;
}

function fillAddress(cell, lab) {
  const stack = document.createElement("div");
  stack.className = "addr-stack";
  cell.append(stack);
  const mode = document.createElement("span");
  mode.className = "mode";
  const pub = wantsPublic(lab);
  mode.textContent = pub ? "Público" : "Privado";
  stack.append(mode);
  const links = pub ? (lab.public_links || []) : (lab.private_links || []);
  if (!links.length) {
    const missing = document.createElement("span");
    missing.textContent = "Sin dirección de red";
    stack.append(missing);
    return;
  }
  for (const link of links) {
    if (lab.running && link.href) {
      const anchor = document.createElement("a");
      anchor.href = link.href;
      anchor.target = "_blank";
      anchor.rel = "noreferrer";
      anchor.textContent = link.text;
      stack.append(anchor);
    } else {
      const text = document.createElement("span");
      text.textContent = link.text;
      stack.append(text);
    }
  }
}

function setNote(text) {
  noteEl.textContent = text || "";
}

function setLabLog(name, text) {
  const clean = (text || "").trim();
  if (clean) logs.set(name, clean);
  else logs.delete(name);
}

async function load() {
  const response = await fetch("/api/labs");
  if (!response.ok) {
    setNote("No se pudo leer el estado de Docker.");
    return;
  }
  const data = await response.json();
  const versionEl = document.querySelector("#banner-version");
  if (versionEl && data.version) versionEl.textContent = data.version;
  draw(data.labs || []);
}

function draw(labs) {
  currentLabs = labs;
  const on = labs.filter((lab) => lab.running).length;
  countEl.textContent = on === 1 ? "1 en marcha" : `${on} en marcha`;
  labsEl.replaceChildren();
  for (const lab of labs) {
    const row = document.createElement("tr");
    if (lab.running) row.classList.add("on");

    const state = document.createElement("td");
    state.className = "state";
    const lamp = document.createElement("span");
    lamp.className = "lamp";
    lamp.setAttribute("role", "img");
    lamp.setAttribute("aria-label", lab.running ? (lab.public ? "En público" : "En marcha") : "Parada");
    state.append(lamp);

    const who = document.createElement("td");
    const name = document.createElement("span");
    name.className = "name";
    name.textContent = lab.name;
    const desc = document.createElement("span");
    desc.className = "desc";
    desc.textContent = lab.desc || "";
    who.append(name, desc);

    const addr = document.createElement("td");
    addr.className = "addr";
    fillAddress(addr, lab);

    const actions = document.createElement("td");
    actions.className = "actions";
    actions.append(modeSwitch(lab), powerSwitch(lab));

    const message = logs.get(lab.name);
    if (message) row.classList.add("has-log");
    row.append(state, who, addr, actions);
    labsEl.append(row);
    if (message) {
      const logRow = document.createElement("tr");
      logRow.className = "lab-log-row";
      const cell = document.createElement("td");
      cell.colSpan = 4;
      const pre = document.createElement("pre");
      pre.className = "lab-log";
      pre.textContent = message;
      cell.append(pre);
      logRow.append(cell);
      labsEl.append(logRow);
      requestAnimationFrame(() => {
        pre.scrollTop = pre.scrollHeight;
      });
    }
  }
}

function powerSwitch(lab) {
  const el = document.createElement("button");
  el.type = "button";
  el.className = "switch";
  el.setAttribute("role", "switch");
  el.setAttribute("aria-checked", lab.running ? "true" : "false");
  const pub = wantsPublic(lab);
  el.setAttribute(
    "aria-label",
    lab.running ? `Apagar ${lab.name}` : `Arrancar ${lab.name} en ${pub ? "público" : "privado"}`,
  );
  el.textContent = lab.running ? "On" : "Off";
  el.addEventListener("click", () => act(lab, lab.running ? "stop" : (pub ? "public" : "start")));
  return el;
}

function modeSwitch(lab) {
  const pub = wantsPublic(lab);
  const el = document.createElement("button");
  el.type = "button";
  el.className = "switch mode";
  el.setAttribute("role", "switch");
  el.setAttribute("aria-checked", pub ? "true" : "false");
  el.setAttribute(
    "aria-label",
    pub
      ? `${lab.name} en público. No enciende la máquina.`
      : `${lab.name} en privado. No enciende la máquina.`,
  );
  el.textContent = pub ? "Público" : "Privado";
  el.disabled = lab.running;
  el.title = lab.running
    ? "Apaga la máquina para cambiar entre privado y público."
    : "Solo elige la dirección. El interruptor de la derecha enciende o apaga.";
  el.addEventListener("click", () => {
    if (lab.running) return;
    marks.set(lab.name, !pub);
    draw(currentLabs);
  });
  return el;
}

async function act(lab, action, confirm) {
  setLabLog(lab.name, action === "stop" ? `Parando ${lab.name}` : `Arrancando ${lab.name}`);
  draw(currentLabs);
  const buttons = labsEl.querySelectorAll("button");
  buttons.forEach((item) => { item.disabled = true; });
  const response = await fetch(`/api/labs/${encodeURIComponent(lab.name)}/${action}`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ confirm: Boolean(confirm) }),
  });
  if (response.status === 409 && action === "public") {
    const data = await response.json();
    const names = (data.running || []).join(", ");
    confirmText.textContent = `En público solo puede haber una máquina. Ahora está ${names}. ¿Apagarla y levantar ${lab.name}?`;
    dialog.showModal();
    const choice = await new Promise((resolve) => {
      dialog.addEventListener("close", () => resolve(dialog.returnValue), { once: true });
    });
    if (choice === "ok") {
      await act(lab, "public", true);
      return;
    }
    setLabLog(lab.name, `Se queda ${names}.`);
    await load();
    return;
  }
  if (!response.ok) {
    const data = await response.json().catch(() => ({}));
    setLabLog(lab.name, data.log || data.error || "No se pudo completar la acción.");
    await load();
    return;
  }
  const data = await response.json();
  setLabLog(lab.name, data.log || "");
  draw(data.labs || []);
}

load().catch(() => setNote("No hay conexión con el panel."));
