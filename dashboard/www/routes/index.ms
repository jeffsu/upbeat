
/*
 * GET home page.
 */

module.exports.setup = #(server, app) {
  app.get('/', #(req, res) {
    res.render('index');
  });
};
