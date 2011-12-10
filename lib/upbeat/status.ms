var HTML = <<END;
html
  head
    link(rel="stylesheet", href="http://twitter.github.com/bootstrap/1.4.0/bootstrap.min.css" )

  body
    div( class="container" )
      for service in services
        h3 #{service.name}
        table
          tr
            th Last Resp Time
            th Avg Resp Time
            th Passed Percentage
            th Status
            th Last Failure
            th Action

          for action in service.actions
            tr
              td #{action.meta.lastResponse || '0'} ms
              td #{action.meta.avgResponse || '0'} ms
              td #{Math.round(action.meta.passedCount / action.meta.count * 100)}%
              td #{action.up ? 'Up' : 'Down'}
              td 
              td #{action.id}
END


var jade = require('jade');

export class Status {
  function initialize() {
    this.$tmpl = jade.compile(HTML);
  }

  function show(services) {
    return this.$tmpl({ services: services }); 
  }
}
