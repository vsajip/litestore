(function(){
  'use strict';
  var app = window.LS || (window.LS = {});
  var u = LS.utils;

  // Search Module
  app.search = {vm: {}};
  app.search.vm.init = function(){
    var vm = this;
    vm.query = m.route.param("q");
    vm.offset = m.route.param("offset") || 0;
    vm.limit = m.route.param("limit") || 10;
    vm.result = m.prop({total: 0, results: []});
    vm.total = 0;
    Doc.search(vm.query, vm.offset, vm.limit).then(function(result){
      vm.result(result);
      vm.total = result.total;
    }, vm.flashError); 
  };
  app.search.main = function(){
    var vm = app.search.vm;
    var result = vm.result();
    var title = m("h2.col-md-12", ["You searched for: ", m("em", vm.query)]);
    var total = m("p.col-md-12", [m("strong", result.total), " hits"]);
    var resultPanel = function(res){
      var obj = {};
      obj.title = res.id;
      obj.content = m("div", [
        m("p", ["Created on: ", u.date(res.created)]),
        m("p", res.tags.map(function(tag){
          return u.taglink(tag);
        }))
        ]
      );
      return m(".row.search-result", m(".col-md-12", [u.panel(obj)]));
    };
    var results = m(".row", [m(".col-md-12", result.results.map(resultPanel))]);
   
    return m("section", [
      m(".row", title),
      m(".row", total),
      m(".row.text-center", [u.paginator(vm)]),
      results,
      m(".row.text-center", [u.paginator(vm)])
    ]);
  };

  u.layout(app.search);

}());