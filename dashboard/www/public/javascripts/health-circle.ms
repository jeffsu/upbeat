function healthCircle(svg) {
  var outer = svg.append('circle');
  var inner = svg.append('circle');

  outer
    .attr('cy', 100)
    .attr('cx', 100)
    .attr('r',  20);

  return #(err, time) {
    outer.transition()
      .duration(1000)
      .attr('fill', err ? 'red' : 'green')
      .attr('r', time);
  };
}

