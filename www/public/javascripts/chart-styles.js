$.elycharts.templates.upbeat = {
  type : "line",
  margins : [20, 20, 25, 20],
  defaultSeries: {
    plotProps: { "stroke-width" : 4 },
    fill: true,
    fillProps: { opacity: .1 },
    dot:  true,
    dotProps : { stroke : "white", "stroke-width" : 2 }
  },

  defaultAxis: { 
    anchors: true,
    labels: true,
    labelsDistance: 15
  },

  features: {
    grid: {
      draw: [true, true],
      props: { "stroke-dasharray" : "-" }
    },

    legend : {
      horizontal: true,

      width: 80,
      height: 50,
      x: 210,
      y: 220,

      dotType: "circle",
      dotProps: {
       stroke: "white",
       "stroke-width" : 2
      },

      borderProps : {
        opacity : 0.3,
        fill : "#c0c0c0",
        "stroke-width" : 0,
        "stroke-opacity" : 0
      }
    }
  },
  axis: {
    r: { 
      labels: true,
      labelsDistance: 2,
      labelsAnchor: "start",
      labelsMargin: 5
    },

    l: {
      labelsDistance: 20,
      labelsAnchor: "start",
      labelsMargin: 5
    }
  }
};

$.elycharts.templates.sensor = {
  template: 'upbeat',
  series: {
    fail: {
      color: "red",
      type: 'line',
      plotProps: { "stroke-width": 0, opacity: 0.3 },
      dotProps: { stroke: "red", "stroke-width": 2, opacity: 0.3 },
    },
    pass: { 
      type: 'line', 
      color: "green", 
      plotProps: { "sroke-width": 0, opacity: 0.5 }
    },
    response: { 
      color: 'blue', 
      type: 'line', 
      axis: 'r', 
      fill: false,
      plotProps: { 'stroke-width': 1 },
      dotProps: { 'stroke-width': .5, stroke: "blue" } 
    }
  }
};
