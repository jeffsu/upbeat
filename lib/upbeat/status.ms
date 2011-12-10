export class Status {
  function json(services) {
    var ret = {};
    for (var name in services) {
      var actions = ret[name] = [];
      var service = services[name];
      foreach (var action in service.actions) {
        actions.push(action.meta);
      }
    }

    return JSON.stringify(ret);
  }
}
