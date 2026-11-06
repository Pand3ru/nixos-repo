// Panel 2: GitHub-style calendar of standing minutes per local day over the last year.
// A = standing minutes per step, B = work minutes per step (step 1h).
const days = dailyMinutes();
const workDays = Object.keys(days).filter((k) => days[k].w > 0);
if (!workDays.length) return noData();

const g = goal();
const today = startOfDay(Date.now());
const WEEKS = 53;
const firstMonday = addDays(today, -weekday(today) - (WEEKS - 1) * 7);

// Split the year into 1-3 stacked bands, whichever gives the biggest square cells
const W = chartW();
const H = chartH();
const left = 30;
const right = 8;
const monthH = 16;
const gapH = 10;
const footH = 18;
let best = { n: 1, cs: 0 };
for (let n = 1; n <= 3; n++) {
  const cols = Math.ceil(WEEKS / n);
  const cs = Math.floor(Math.min((W - left - right) / cols, (H - footH - n * monthH - (n - 1) * gapH) / (7 * n)));
  // more bands only if the cells get clearly bigger
  if (cs > best.cs * 1.2) best = { n, cs };
}
const cs = Math.max(4, Math.min(best.cs, 22));
const perBand = Math.ceil(WEEKS / best.n);
const usedH = best.n * (7 * cs + monthH) + (best.n - 1) * gapH;
const top0 = Math.max(0, Math.floor((H - usedH - footH) / 2));
const x0 = Math.max(0, Math.floor((W - right - left - perBand * cs) / 2)) + left;

const bands = [];
for (let i = 0; i < best.n; i++) {
  const start = addDays(firstMonday, i * perBand * 7);
  if (start > today) break;
  let end = addDays(start, perBand * 7 - 1);
  if (end > today) end = today;
  bands.push({ start: dayKey(start), end: dayKey(end) });
}

const orange = (a) => 'rgba(255,140,66,' + a + ')';
const pieces = [
  { lt: 1, color: theme.isDark ? 'rgba(255,255,255,0.13)' : 'rgba(0,0,0,0.13)' },
  { gte: 1, lt: g / 3, color: orange(0.3) },
  { gte: g / 3, lt: (2 * g) / 3, color: orange(0.55) },
  { gte: (2 * g) / 3, lt: g, color: orange(0.8) },
  { gte: g, color: C.accent },
];

const data = workDays.map((k) => [k, Math.round(days[k].s), Math.round(days[k].w)]);
const met = data.filter((d) => d[1] >= g).length;
const gap = cs >= 10 ? 2 : 1;

return {
  tooltip: {
    ...tooltipBase,
    formatter: (p) => {
      const [y, m, d] = p.value[0].split('-').map(Number);
      return dateLabel(new Date(y, m - 1, d)) + ': ' + fmtMin(p.value[1]) + ' standing' +
        '<br/><span style="opacity:.7">of ' + fmtMin(p.value[2]) + ' work</span>';
    },
  },
  visualMap: { type: 'piecewise', show: false, dimension: 1, pieces, seriesIndex: bands.map((_, i) => i) },
  calendar: bands.map((b, i) => ({
    orient: 'horizontal',
    range: [b.start, b.end],
    left: x0,
    top: top0 + monthH + i * (7 * cs + monthH + gapH),
    cellSize: [cs, cs],
    firstDay: 1,
    splitLine: { show: false },
    itemStyle: { color: C.empty, borderColor: C.bg, borderWidth: gap },
    yearLabel: { show: false },
    monthLabel: { ...axisText, margin: 4 },
    dayLabel: { ...axisText, fontSize: Math.min(10, Math.max(8, cs - 1)), firstDay: 1, margin: 4, nameMap: ['', 'Mon', '', 'Wed', '', 'Fri', ''] },
  })),
  series: bands.map((_, i) => ({
    type: 'heatmap',
    coordinateSystem: 'calendar',
    calendarIndex: i,
    data: data.filter((d) => d[0] >= bands[i].start && d[0] <= bands[i].end),
    itemStyle: { borderColor: C.bg, borderWidth: gap, borderRadius: cs >= 10 ? 2 : 0 },
  })),
  graphic: [
    {
      type: 'text',
      left: x0,
      top: top0 + usedH + 4,
      style: {
        text: 'Goal of ' + g + ' min met on ' + met + ' of ' + data.length + ' work days',
        fill: C.muted,
        font: '11px ' + C.font,
      },
    },
  ],
};
