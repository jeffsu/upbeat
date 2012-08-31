var CHART_TIME = 'min';

function startChart(par) {
  var $div = $(par);
  var url  = $div.data('url');
  var type = $div.data('type');

  function go() {
    $.get(url, function (payload) {
      $div.chart({
        template: type,
        values:   payload.data,
        labels:   payload.labels
      });
    });
    setTimeout(go, 2000);
  }

  go();
}

