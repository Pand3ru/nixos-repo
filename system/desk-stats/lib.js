// Shared helpers, prepended to every Business Charts panel function in desk-stats.nix.
// Runs as `new Function('context', lib + panel)`; the panel part must `return` an ECharts option.
const theme = context.grafana.theme;
const C = {
  accent: '#ff8c42',
  text: theme.colors.text.primary,
  muted: theme.colors.text.secondary,
  bg: theme.colors.background.primary,
  grid: theme.colors.border.weak,
  // empty calendar cell / "no work day"
  empty: theme.isDark ? 'rgba(255,255,255,0.06)' : 'rgba(0,0,0,0.06)',
  sit: theme.isDark ? '#6b717d' : '#a7acb5',
  font: theme.typography.fontFamily,
};
const MIN = 60000;
const HOUR = 60 * MIN;
const DAY = 24 * HOUR;
const WEEKDAYS = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

const chartW = () => (context.panel.chart && context.panel.chart.getWidth()) || 400;
const chartH = () => (context.panel.chart && context.panel.chart.getHeight()) || 250;

// Field values are plain arrays in Grafana 13; older Vector types had .buffer / .toArray()
const arr = (v) => (!v ? [] : Array.isArray(v) ? v : v.buffer ? Array.from(v.buffer) : v.toArray ? v.toArray() : Array.from(v));

// All frames of one query (refId)
const frames = (refId) => (context.panel.data.series || []).filter((f) => f.refId === refId);

// [[timestampMs, value], ...] of one query, sorted, nulls/NaN dropped
function points(refId) {
  const out = [];
  for (const f of frames(refId)) {
    const tf = (f.fields || []).find((x) => x.type === 'time');
    const vf = (f.fields || []).find((x) => x.type === 'number');
    if (!tf || !vf) continue;
    const ts = arr(tf.values);
    const vs = arr(vf.values);
    for (let i = 0; i < ts.length; i++) {
      const v = vs[i];
      if (v === null || v === undefined || !isFinite(v)) continue;
      out.push([+ts[i], +v]);
    }
  }
  return out.sort((a, b) => a[0] - b[0]);
}

// Last value of an instant query, optionally filtered by a label
function lastValue(refId, label, value) {
  for (const f of frames(refId)) {
    const vf = (f.fields || []).find((x) => x.type === 'number');
    if (!vf || (label && !(vf.labels && vf.labels[label] === value))) continue;
    const vs = arr(vf.values).filter((v) => v !== null && isFinite(v));
    if (vs.length) return +vs[vs.length - 1];
  }
  return undefined;
}

// Query step: smallest gap between samples, else what Grafana requested
function stepOf(pts) {
  let s = Infinity;
  for (let i = 1; i < pts.length; i++) s = Math.min(s, pts[i][0] - pts[i - 1][0]);
  if (isFinite(s) && s > 0) return s;
  const r = context.panel.data.request;
  return (r && r.intervalMs) || MIN;
}

const pad = (n) => String(n).padStart(2, '0');
const dayKey = (d) => d.getFullYear() + '-' + pad(d.getMonth() + 1) + '-' + pad(d.getDate());
const startOfDay = (ms) => {
  const d = new Date(ms);
  d.setHours(0, 0, 0, 0);
  return d;
};
const addDays = (d, n) => {
  const x = new Date(d);
  x.setDate(x.getDate() + n);
  return x;
};
// Monday = 0
const weekday = (d) => (d.getDay() + 6) % 7;
const clock = (min) => pad(Math.floor(min / 60) % 24) + ':' + pad(Math.round(min % 60));
const dateLabel = (d) => d.toLocaleDateString(undefined, { weekday: 'short', day: 'numeric', month: 'short' });

function fmtMin(m) {
  m = Math.round(m);
  const h = Math.floor(m / 60);
  return h ? h + ' h ' + (m % 60) + ' min' : m + ' min';
}

function goal() {
  const g = parseFloat(context.grafana.replaceVariables('$goal'));
  return isFinite(g) && g > 0 ? g : 60;
}

// Per local day: standing (A) and work (B) minutes. Each sample at t holds the window (t - step, t].
function dailyMinutes(range) {
  const days = {};
  const add = (refId, key) => {
    for (const [t, v] of points(refId)) {
      const k = dayKey(new Date(t - 1));
      (days[k] = days[k] || { s: 0, w: 0 })[key] += v;
    }
  };
  add('A', 's');
  add('B', 'w');
  return days;
}

const noData = (text) => ({
  graphic: [
    {
      type: 'text',
      left: 'center',
      top: 'middle',
      style: { text: text || 'No data yet', fill: C.muted, font: '14px ' + C.font },
    },
  ],
});

// Stat-like tiles drawn with graphic text: [{ label, value, sub, color }]
function tiles(list) {
  const w = chartW();
  const h = chartH();
  const cols = list.length;
  const tw = w / cols;
  const fs = Math.max(14, Math.min(h * 0.32, (tw / Math.max(4, ...list.map((t) => String(t.value).length))) * 1.6, 44));
  const els = [];
  list.forEach((t, i) => {
    const x = tw * i + tw / 2;
    const y = h / 2 - (t.sub ? fs * 0.25 : 0);
    els.push({
      type: 'text',
      x,
      y: y - fs * 0.62 - 6,
      style: { text: t.label, fill: C.muted, font: Math.round(Math.max(11, fs * 0.3)) + 'px ' + C.font, align: 'center', verticalAlign: 'bottom' },
    });
    els.push({
      type: 'text',
      x,
      y,
      style: { text: String(t.value), fill: t.color || C.text, font: '500 ' + Math.round(fs) + 'px ' + C.font, align: 'center', verticalAlign: 'middle' },
    });
    if (t.sub) {
      els.push({
        type: 'text',
        x,
        y: y + fs * 0.62 + 4,
        style: { text: t.sub, fill: C.muted, font: Math.round(Math.max(10, fs * 0.28)) + 'px ' + C.font, align: 'center', verticalAlign: 'top' },
      });
    }
  });
  return { graphic: els };
}

const tooltipBase = {
  backgroundColor: theme.colors.background.secondary,
  borderColor: C.grid,
  textStyle: { color: C.text, fontFamily: C.font, fontSize: 12 },
  confine: true,
};
const axisText = { color: C.muted, fontFamily: C.font, fontSize: 10 };

