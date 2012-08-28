$.elycharts.templates['pass-fail'] = {
 type : "line",
 margins : [10, 10, 20, 50],
 defaultSeries : {
  plotProps : {
   "stroke-width" : 4
  },
  dot : true,
  dotProps : {
   stroke : "white",
   "stroke-width" : 2
  }
 },
 series : {
  fail : {
   color : "red",
   plotProps: {
     "stroke-width": 0
   },
   dotProps: {
     stroke: "red",
     "stroke-width": 2
   },
   startAnimation: { type: 'reg', delay: 100, easing: 'elastic' }
  },
  pass : {
   color : "green",
   startAnimation: { type: 'reg', delay: 100, easing: 'elastic' }
  }
 },
 defaultAxis : {
  labels : true
 },
 features : {
  grid : {
   draw : [true, false],
   props : {
    "stroke-dasharray" : "-"
   }
  },
  legend : {
   horizontal : false,
   width : 80,
   height : 50,
   x : 210,
   y : 220,
   dotType : "circle",
   dotProps : {
    stroke : "white",
    "stroke-width" : 2
   },
   borderProps : {
    opacity : 0.3,
    fill : "#c0c0c0",
    "stroke-width" : 0,
    "stroke-opacity" : 0
   }
  }
 }
};

$.elycharts.templates['lines'] = {
 type : "line",
 margins : [10, 10, 20, 50],
 defaultSeries : {
  plotProps : {
   "stroke-width" : 4
  },
  dot : true,
  dotProps : {
   stroke : "white",
   "stroke-width" : 2
  }
 },
 series : {
  fail : {
   color : "red",
   plotProps: {
     "stroke-width": 0
   },
   dotProps: {
     stroke: "red",
     "stroke-width": 2
   },
   startAnimation: { type: 'reg', delay: 100, easing: 'elastic' }
  },
  pass : {
   color : "green",
   startAnimation: { type: 'reg', delay: 100, easing: 'elastic' }
  }
 },
 defaultAxis : {
  labels : true
 },
 features : {
  grid : {
   draw : [true, false],
   props : {
    "stroke-dasharray" : "-"
   }
  },
  legend : {
   horizontal : false,
   width : 80,
   height : 50,
   x : 210,
   y : 220,
   dotType : "circle",
   dotProps : {
    stroke : "white",
    "stroke-width" : 2
   },
   borderProps : {
    opacity : 0.3,
    fill : "#c0c0c0",
    "stroke-width" : 0,
    "stroke-opacity" : 0
   }
  }
 }
};

