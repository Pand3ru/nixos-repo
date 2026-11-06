// Panel 4: standing vs sitting per local day (stacked, hours), dashed line = daily standing goal.
// A = standing minutes per step, B = work minutes per step.
const days = dailyMinutes();
if (!Object.values(days).some((d) => d.w > 0)) return noData();

const g = goal();
const last = startOfDay(Date.now());
const first = addDays(last, -29);
const cats = [];
const stand = [];
const sit = [];
for (let d = first; d <= last; d = addDays(d, 1)) {
  const v = days[dayKey(d)] || { s: 0, w: 0 };
  cats.push(d);
  stand.push(+(v.s / 60).toFixed(2));
  sit.push(+(Math.max(0, v.w - v.s) / 60).toFixed(2));
}

const narrow = chartW() < 520;
return {
  grid: { left: 8, right: 12, top: 18, bottom: 4, containLabel: true },
  tooltip: {
    ...tooltipBase,
    trigger: 'axis',
    axisPointer: { type: 'shadow' },
    formatter: (ps) => {
      const i = ps[0].dataIndex;
      const s = stand[i] * 60;
      const w = s + sit[i] * 60;
      return dateLabel(cats[i]) + '<br/>' +
        '<span style="color:' + C.accent + '">■</span> Standing ' + fmtMin(s) + (w ? ' (' + Math.round((s / w) * 100) + ' %)' : '') + '<br/>' +
        '<span style="color:' + C.sit + '">■</span> Sitting ' + fmtMin(w - s);
    },
  },
  xAxis: {
    type: 'category',
    data: cats.map((d) => (narrow ? String(d.getDate()) : d.getDate() + '.' + (d.getMonth() + 1) + '.')),
    axisTick: { show: false },
    axisLine: { lineStyle: { color: C.grid } },
    axisLabel: { ...axisText, hideOverlap: true },
  },
  yAxis: {
    type: 'value',
    minInterval: 1,
    splitLine: { lineStyle: { color: C.grid } },
    axisLabel: { ...axisText, formatter: (v) => v + ' h' },
  },
  series: [
    {
      name: 'Standing',
      type: 'bar',
      stack: 'day',
      data: stand,
      itemStyle: { color: C.accent },
      barCategoryGap: '25%',
      markLine: {
        silent: true,
        symbol: 'none',
        data: [{ yAxis: g / 60 }],
        lineStyle: { color: C.accent, type: 'dashed', width: 1, opacity: 0.8 },
        label: { show: true, position: 'insideEndTop', formatter: 'goal', color: C.accent, fontSize: 10, fontFamily: C.font },
      },
    },
    {
      name: 'Sitting',
      type: 'bar',
      stack: 'day',
      data: sit,
      itemStyle: { color: C.sit, borderRadius: [2, 2, 0, 0] },
    },
  ],
};
