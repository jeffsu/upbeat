var CHART_TIME = 'min';

function startChart(par) {
  var $div = $(par);
  var url  = $div.data('url');
  var type = $div.data('type');

  function go() {
    $.get(url, function (payload) {
      var series = type != 'sensor' ? getSeries(payload.data) : {};

      $div.chart({
        template: type,
        values:   payload.data,
        labels:   payload.labels,
        series:   series
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
