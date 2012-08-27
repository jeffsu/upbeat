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
          legend: {
            fail: "Failures",
            pass: "Passes"
          }
        });
        setTimeout(function () { getData() }, 2000);
      });
    }

    getData();
  });
});
