$(function () {
  $('.chart').each(function () {
    var $chart = $(this);
    var url    = $chart.data('url');
    var type   = $chart.data('type');

    function getData() {
      $.get(url, function (data, err) {
        var $div   = $('<div></div>');
        $chart.html($div);
        $div.chart({
          template: type,
          values:   data,
          legend: getLegend(type, data),
          series: getSeries(type, data)
        });
        setTimeout(function () { getData() }, 2000);
      });
    }

    getData();
  });

  var COLORS = [
    "EFDECD",
    "78DBE2",
    "FFA474",
    "FAE7B5",
    "CB4154",
    "1CD3A2",
    "FFAACC",
    "1DACD6",
    "FFFF99",
    "A2A2D0",
    "000000"
  ];

  var COLOR_IDX = 0;

  function getSeriesItem(color, width) {
    return {
      color: color || ('#' + COLORS[COLOR_IDX++%COLORS.length]),
      "stroke-width": width === undefined ? 1 : width,
      startAnimation: { type: 'reg', delay: 100, easing: 'elastic' }
    };
  }

  function getLegend(type, data) {
    var ret = {};
    for (var key in data) ret[key] = key; 
    return ret;
  }

  function getSeries(type, data) {
    COLOR_IDX = 0;
    var series = {};
    if (type == 'lines') {
      var i = 0;
      for (var key in data) {
        i++;
        series[key] = getSeriesItem();
      }
    } else if (type = 'pass-fail') {
      series.fail = getSeriesItem('red', 0);
      series.pass = getSeriesItem('green', 2);
    }
    console.log(series);
    return series;
  }
});
