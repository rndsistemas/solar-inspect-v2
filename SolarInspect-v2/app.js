const STORAGE_KEY = "solarinspect_modules_v2";
const LEGACY_STORAGE_KEY = "solarinspect_modules_v1";

const statusConfig = {
  nao_inspecionado: { label: "Não inspecionado", color: "#7b8794" },
  normal: { label: "Normal", color: "#198754" },
  leve: { label: "Defeito leve", color: "#e0a800" },
  medio: { label: "Defeito médio", color: "#e67e22" },
  critico: { label: "Crítico", color: "#dc3545" },
  concluido: { label: "Concluído", color: "#0d6efd" }
};

const parkCenter = [-8.0505, -34.9380];
let map;
let modules = loadModules();
let markers = new Map();
let selectedModuleId = null;
let pendingPhotos = [];

function generateDemoModules() {
  const result = [];
  const baseLat = -8.0522;
  const baseLng = -34.9408;
  let id = 1;

  for (let block = 1; block <= 3; block++) {
    for (let table = 1; table <= 8; table++) {
      for (let module = 1; module <= 12; module++) {
        const row = Math.floor((table - 1) / 4);
        const colGroup = (table - 1) % 4;
        const lat = baseLat + block * 0.00115 + row * 0.00034 + (module % 2) * 0.000045;
        const lng = baseLng + colGroup * 0.00052 + Math.floor(module / 2) * 0.000055;

        result.push({
          id: `MOD-${String(id).padStart(4, "0")}`,
          park: "Complexo Solar SOLAR INSPECT",
          block: `B${String(block).padStart(2, "0")}`,
          table: `MESA-${String(table).padStart(3, "0")}`,
          string: `STR-${String(Math.ceil(module / 4)).padStart(2, "0")}`,
          position: `M${String(module).padStart(2, "0")}`,
          lat,
          lng,
          status: "nao_inspecionado",
          inspections: []
        });
        id++;
      }
    }
  }
  return result;
}

function loadModules() {
  try {
    const saved = localStorage.getItem(STORAGE_KEY) || localStorage.getItem(LEGACY_STORAGE_KEY);
    if (!saved) return generateDemoModules();

    const parsed = JSON.parse(saved);
    if (!Array.isArray(parsed) || !parsed.length) return generateDemoModules();

    return parsed.map(item => ({
      ...item,
      status: statusConfig[item.status] ? item.status : "nao_inspecionado",
      inspections: Array.isArray(item.inspections) ? item.inspections : []
    }));
  } catch (error) {
    console.warn("Dados locais inválidos; carregando demonstração.", error);
    return generateDemoModules();
  }
}

function saveModules() {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(modules));
    localStorage.removeItem(LEGACY_STORAGE_KEY);
    return true;
  } catch (error) {
    console.error("Falha ao salvar dados locais.", error);
    if (error?.name === "QuotaExceededError") {
      showToast("Armazenamento cheio. Remova fotos antigas ou exporte os dados antes de continuar.");
    } else {
      showToast("Não foi possível salvar os dados neste navegador.");
    }
    return false;
  }
}

function initMap() {
  const mapElement = document.getElementById("map");
  if (typeof window.L === "undefined") {
    mapElement.innerHTML = `<div class="map-error"><strong>Mapa indisponível.</strong><br>Verifique a conexão com a internet e recarregue a página.</div>`;
    showToast("Não foi possível carregar o mapa.");
    return;
  }

  map = L.map("map", { preferCanvas: true }).setView(parkCenter, 17);

  L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
    maxZoom: 19,
    attribution: "&copy; OpenStreetMap"
  }).addTo(map);

  const boundary = [
    [-8.0530, -34.9414],
    [-8.0494, -34.9414],
    [-8.0494, -34.9361],
    [-8.0530, -34.9361]
  ];

  L.polygon(boundary, {
    color: "#0f5132",
    weight: 2,
    fillOpacity: 0.04
  }).addTo(map).bindTooltip("Complexo Solar SOLAR INSPECT");

  renderMarkers();
}

function createModuleIcon(status) {
  const color = (statusConfig[status] || statusConfig.nao_inspecionado).color;
  return L.divIcon({
    className: "",
    html: `<div class="module-icon" style="width:9px;height:18px;background:${color}"></div>`,
    iconSize: [9, 18],
    iconAnchor: [4.5, 9]
  });
}

function renderMarkers() {
  markers.forEach(marker => marker.remove());
  markers.clear();

  const filter = document.getElementById("statusFilter").value;
  const search = document.getElementById("searchInput").value.trim().toLowerCase();

  modules.forEach(module => {
    const text = `${module.id} ${module.block} ${module.table} ${module.string} ${module.position}`.toLowerCase();
    const matchesFilter = filter === "todos" || module.status === filter;
    const matchesSearch = !search || text.includes(search);
    if (!matchesFilter || !matchesSearch) return;

    const marker = L.marker([module.lat, module.lng], {
      icon: createModuleIcon(module.status)
    }).addTo(map);

    marker.bindTooltip(
      `<strong>${module.id}</strong><br>${module.block} • ${module.table} • ${module.position}<br>${(statusConfig[module.status] || statusConfig.nao_inspecionado).label}`
    );

    marker.on("click", () => selectModule(module.id));
    markers.set(module.id, marker);
  });
}

function selectModule(moduleId) {
  selectedModuleId = moduleId;
  const module = modules.find(m => m.id === moduleId);
  if (!module) return;

  document.getElementById("emptyState").classList.add("hidden");
  document.getElementById("modulePanel").classList.remove("hidden");

  document.getElementById("moduleTitle").textContent = module.id;
  document.getElementById("moduleLocation").textContent = `${module.block} • ${module.table} • ${module.position}`;
  document.getElementById("parkName").textContent = module.park;
  document.getElementById("blockName").textContent = module.block;
  document.getElementById("tableName").textContent = module.table;
  document.getElementById("stringName").textContent = module.string;
  document.getElementById("coordinates").textContent = `${module.lat.toFixed(6)}, ${module.lng.toFixed(6)}`;

  const badge = document.getElementById("statusBadge");
  const currentStatus = statusConfig[module.status] || statusConfig.nao_inspecionado;
  badge.textContent = currentStatus.label;
  badge.style.background = currentStatus.color;

  document.getElementById("inspectionStatus").value =
    module.status === "nao_inspecionado" ? "normal" : module.status;

  pendingPhotos = [];
  document.getElementById("photoPreview").innerHTML = "";
  document.getElementById("photoInput").value = "";
  renderHistory(module);

  if (map) map.panTo([module.lat, module.lng]);
}

function renderHistory(module) {
  const container = document.getElementById("historyList");
  if (!module.inspections.length) {
    container.innerHTML = "<p>Nenhuma inspeção registrada.</p>";
    return;
  }

  container.innerHTML = module.inspections
    .slice()
    .reverse()
    .map(item => `
      <article class="history-item">
        <strong>${(statusConfig[item.status] || statusConfig.nao_inspecionado).label} — ${escapeHtml(item.defectType || "Sem ocorrência")}</strong>
        <p><strong>Data:</strong> ${new Date(item.date).toLocaleString("pt-BR")}</p>
        <p><strong>Responsável:</strong> ${escapeHtml(item.inspector)}</p>
        <p><strong>Observações:</strong> ${escapeHtml(item.notes || "Sem observações")}</p>
        ${item.photos?.length ? `
          <div class="images">
            ${item.photos.map(src => `<img src="${src}" alt="Foto da inspeção" />`).join("")}
          </div>` : ""}
      </article>
    `).join("");
}

function escapeHtml(value) {
  return String(value)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#039;");
}

document.getElementById("inspectionForm").addEventListener("submit", event => {
  event.preventDefault();
  const module = modules.find(m => m.id === selectedModuleId);
  if (!module) return;

  const inspection = {
    date: new Date().toISOString(),
    status: document.getElementById("inspectionStatus").value,
    defectType: document.getElementById("defectType").value,
    inspector: document.getElementById("inspectorName").value.trim(),
    notes: document.getElementById("notes").value.trim(),
    photos: pendingPhotos
  };

  const previousStatus = module.status;
  module.status = inspection.status;
  module.inspections.push(inspection);

  if (!saveModules()) {
    module.inspections.pop();
    module.status = previousStatus;
    return;
  }

  renderMarkers();
  selectModule(module.id);

  document.getElementById("notes").value = "";
  showToast("Inspeção salva com sucesso.");
});

document.getElementById("photoInput").addEventListener("change", async event => {
  const files = Array.from(event.target.files || []).slice(0, 4);
  pendingPhotos = await Promise.all(files.map(resizeImage));
  document.getElementById("photoPreview").innerHTML =
    pendingPhotos.map(src => `<img src="${src}" alt="Prévia da fotografia" />`).join("");
});

function resizeImage(file) {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onerror = reject;
    reader.onload = () => {
      const image = new Image();
      image.onload = () => {
        const max = 700;
        const scale = Math.min(1, max / Math.max(image.width, image.height));
        const canvas = document.createElement("canvas");
        canvas.width = Math.round(image.width * scale);
        canvas.height = Math.round(image.height * scale);
        const ctx = canvas.getContext("2d");
        ctx.drawImage(image, 0, 0, canvas.width, canvas.height);
        resolve(canvas.toDataURL("image/jpeg", 0.68));
      };
      image.onerror = reject;
      image.src = reader.result;
    };
    reader.readAsDataURL(file);
  });
}

document.getElementById("locateBtn").addEventListener("click", () => {
  if (!map) {
    showToast("O mapa ainda não está disponível.");
    return;
  }
  if (!navigator.geolocation) {
    showToast("Geolocalização não disponível.");
    return;
  }

  navigator.geolocation.getCurrentPosition(
    position => {
      const latlng = [position.coords.latitude, position.coords.longitude];
      map.setView(latlng, 19);
      L.circleMarker(latlng, {
        radius: 8,
        color: "#0d6efd",
        fillColor: "#0d6efd",
        fillOpacity: 0.75
      }).addTo(map).bindPopup("Sua localização atual").openPopup();
    },
    () => showToast("Não foi possível obter sua localização."),
    { enableHighAccuracy: true, timeout: 12000 }
  );
});

document.getElementById("statusFilter").addEventListener("change", renderMarkers);
document.getElementById("searchInput").addEventListener("input", renderMarkers);

document.getElementById("exportBtn").addEventListener("click", () => {
  const rows = [["Modulo", "Parque", "Bloco", "Mesa", "String", "Posicao", "Latitude", "Longitude", "Status", "Ultima_inspecao", "Defeito", "Responsavel", "Observacoes"]];
  modules.forEach(module => {
    const last = module.inspections[module.inspections.length - 1] || {};
    rows.push([
      module.id, module.park, module.block, module.table, module.string, module.position,
      module.lat, module.lng, statusConfig[module.status].label,
      last.date || "", last.defectType || "", last.inspector || "", last.notes || ""
    ]);
  });

  const csv = rows.map(row => row.map(value => `"${String(value).replaceAll('"', '""')}"`).join(";")).join("\n");
  const blob = new Blob(["\uFEFF" + csv], { type: "text/csv;charset=utf-8" });
  const url = URL.createObjectURL(blob);
  const link = document.createElement("a");
  link.href = url;
  link.download = `solar-inspect-modulos-${new Date().toISOString().slice(0,10)}.csv`;
  link.click();
  URL.revokeObjectURL(url);
});

document.getElementById("resetBtn").addEventListener("click", () => {
  if (!confirm("Apagar inspeções e restaurar os dados de demonstração?")) return;
  modules = generateDemoModules();
  if (!saveModules()) return;
  selectedModuleId = null;
  document.getElementById("modulePanel").classList.add("hidden");
  document.getElementById("emptyState").classList.remove("hidden");
  renderMarkers();
  showToast("Dados de demonstração restaurados.");
});

function showToast(message) {
  const toast = document.getElementById("toast");
  toast.textContent = message;
  toast.style.display = "block";
  setTimeout(() => toast.style.display = "none", 2600);
}

if ("serviceWorker" in navigator) {
  navigator.serviceWorker.register("service-worker.js").catch(() => {});
}

try {
  initMap();
} catch (error) {
  console.error("Falha ao inicializar o mapa.", error);
  document.getElementById("map").innerHTML = `<div class="map-error"><strong>Erro ao iniciar o mapa.</strong><br>Recarregue a página ou verifique a conexão.</div>`;
  showToast("Erro ao iniciar o mapa.");
}


window.addEventListener("load", () => {
  setTimeout(() => document.getElementById("splash")?.classList.add("hide"), 850);
});
