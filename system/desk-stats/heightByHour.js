// Panel 3: time spent per (local hour of day, 20 mm height band) during work days.
// A = desk:height_working_mm sampled every step; each sample stands for `step` of time.
const pts = points('A');
if (!pts.length) return noData();

const BIN = 20;
const stepMin = stepOf(pts) / MIN;
const cells = {};
let h0 = 23;
let h1 = 0;
for (const [t, v] of pts) {
  const hour = new Date(t).getHours();
  const b = Math.floor(v / BIN) * BIN;
  const k = hour + ':' + b;
  cells[k] = (cells[k] || 0) + stepMin;
  h0 = Math.min(h0, hour);
  h1 = Math.max(h1, hour);
}
// at least a 6-hour window
while (h1 - h0 < 5) h0 > 0 ? h0-- : h1++;
const hours = [];
for (let h = h0; h <= h1; h++) hours.push(h);

// Only height bands that actually get used (the desk mostly sits at its two presets),
// so the rows stay readable in a small embed; passing-through heights are dropped.
const perBand = {};
let total = 0;
for (const k in cells) {
  const b = +k.split(':')[1];
  perBand[b] = (perBand[b] || 0) + cells[k];
  total += cells[k];
}
const bands = Object.keys(perBand).map(Number).filter((b) => perBand[b] >= Math.max(5, total * 0.003)).sort((a, b) => a - b);

const data = [];
let max = 0;
hours.forEach((h, x) => bands.forEach((b, y) => {
  const m = cells[h + ':' + b];
  if (m) {
    data.push([x, y, Math.sqrt(m), Math.round(m)]);
    max = Math.max(max, Math.sqrt(m));
  }
}));

return {
  grid: { left: 6, right: 10, top: 10, bottom: 4, containLabel: true },
  tooltip: {
    ...tooltipBase,
    formatter: (p) => pad(hours[p.value[0]]) + '–' + pad(hours[p.value[0]] + 1) + ' h, ' +
      bands[p.value[1]] + '–' + (bands[p.value[1]] + BIN) + ' mm<br/>' + fmtMin(p.value[3]),
  },
  xAxis: {
    type: 'category',
    data: hours.map(String),
    splitArea: { show: false },
    axisTick: { show: false },
    axisLine: { show: false },
    axisLabel: { ...axisText, hideOverlap: true },
  },
  yAxis: {
    type: 'category',
    data: bands.map((b) => String(b)),
    axisTick: { show: false },
    axisLine: { show: false },
    axisLabel: { ...axisText, hideOverlap: true },
  },
  visualMap: {
    show: false,
    dimension: 2, // sqrt(minutes), so short stays are still visible next to hours of sitting
    min: 0,
    max: Math.max(1, max),
    inRange: { color: ['rgba(255,140,66,0.12)', 'rgba(255,140,66,0.55)', C.accent] },
  },
  series: [
    {
      type: 'heatmap',
      data,
      itemStyle: { borderColor: C.bg, borderWidth: 1, borderRadius: 2 },
      emphasis: { itemStyle: { borderColor: C.text, borderWidth: 1 } },
    },
  ],
};
