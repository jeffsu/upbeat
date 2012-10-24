var CHART_TIMEOUTS = {
  min: 2,
  hour: 20,
  day:  60,
  week: 3600
};

function startChart(par) {
  var $div = $(par);
  var url  = $div.data('url');
  var type = $div.data('type');
  var first = true;
  var m = url.match(/time=(\w+)/);
  var time = null;
  if (m) time = m[1];
  var timeout = CHART_TIMEOUTS[time] || CHART_TIMEOUTS.min;

  function go() {
    $.get(url, function (payload) {
      var data = payload.data;
      if (data) {
        for (var k in data) {
          if (data[k] instanceof Array) 
            data[k] = data[k].reverse();
        }
      }


      if (!first) {
        return $div.chart({ values: payload.data });
      } else {
        first = false;
      }

      var series = type != 'sensor' ? getSeries(payload.data) : {};
      var legend = {};
      var values = payload.data;
      var labels = payload.labels;

      if (type == 'upbeat-pie') {
        legend = labels;
      } else {
        for (var k in payload.data) legend[k] = k;
      }

      $div.chart({
        template: type,
        values:   values,
        labels:   labels,
        series:   series,
        legend:   legend
      });
    });

    setTimeout(go, timeout * 1000);
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
  'pink',
  'orange'
];

var USED_COLORS = {};
var COLOR_IDX   = 0;

function getOneSeries(name) {
  return {
    color: getColor(name)
  };
}

function getColor(name) {
  return USED_COLORS[name] || (USED_COLORS[name] = COLORS[COLOR_IDX++%COLORS.length]);
}
