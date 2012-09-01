var CHART_TIME = 'min';

function startChart(par) {
  var $div = $(par);
  var url  = $div.data('url');
  var type = $div.data('type');
  var first = true;

  function go() {
    $.get(url, function (payload) {
      if (!first) {
        return $div.chart({ values: payload.data });
      } else {
        first = false;
      }

      var series = type != 'sensor' ? getSeries(payload.data) : {};
      var legend = {};
      var values = payload.data;
      var labels = payload.labels;

      for (var k in payload.data) legend[k] = k;
      if (type == 'upbeat-pie') {
        legend = labels;
      }

      $div.chart({
        template: type,
        values:   values,
        labels:   labels,
        series:   series,
        legend:   legend
      });
    });
    setTimeout(go, 2000);
  }

  go();
}

function getSeries(data) {
  var ret = {};
  for (var k in data) {
    ret[k] = getOneSeries(k); 
  }
  return ret;
}

var COLORS = [
  'blue',
  'red',
  'green',
  'yellow',
  'pink'
];

var USED_COLORS = {};
var COLOR_IDX   = 0;

function getOneSeries(name) {
  return {
    color: getColor(name)
  };
}

function getColor(name) {
  return USED_COLORS[name] || (USED_COLORS[name] = COLORS[COLOR_IDX++]);
}
