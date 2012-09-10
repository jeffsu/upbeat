$.elycharts.templates.upbeat = {
  type : "line",
  margins : [20, 20, 25, 20],
  tooltips: function (serialId, valueIdx, allValues, singleValue) {
    return Math.round(singleValue);
  },

  defaultSeries: {
    plotProps: { "stroke-width" : 2 },
    fill: true,
    fillProps: { opacity: .1 },
    dot:  true,
    dotProps : { stroke : "black", "stroke-width": 1 }
  },

  defaultAxis: { 
    anchors: true,
    labels: true,
    labelsDistance: 15
  },

  features: {
    grid: {
      draw: [true, true],
      props: { 
        "stroke-dasharray" : "-",
      }
    },

    legend : {
      horizontal: false,
      width: 200,
      height: 100,

      x: 100,
      y: 150,
      
      dotType: "circle",
      dotProps: {
       stroke: "white",
       "stroke-width" : 1.5,
       "stroke-opacity" : 0.5
      },

      borderProps : {
        opacity : 0.3,
        fill : "#c0c0c0",
        "stroke-width" : 0,
        "stroke-opacity" : 0.5
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
      dotProps: { stroke: "red", "stroke-width": 2, opacity: 1 },
    },
    pass: { 
      type: 'line', 
      color: "green", 
      plotProps: { "stroke-width": 3, opacity: 0.5 }
    },

    timeout: {
      type: 'line',
      color: 'black',
      dot: true,
      fill: false,
      plotProps: { "stroke-width": 0 },
      dotProps:  { "stroke": "black", "stroke-width": 1, opacity: 1 }
    },

    slow: {
      type: 'line',
      color: 'yellow', 
      dot: true,
      plotProps: { "stroke-width": 2 },
      dotProps:  { "stroke": "red", "stroke-width": 1, opacity: 1 }
    },

    fast: {
      type: 'line',
      color: 'purple', 
      dot: true,
      plotProps: { "stroke-width": 2 },
      dotProps:  { "stroke": "purple", "stroke-width": 1, opacity: 0.3 }
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

$.elycharts.templates['upbeat-pie'] = {
  template: 'upbeat',
  type: "pie"
};
