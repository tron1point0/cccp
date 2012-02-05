#!/usr/bin/node
(function() {
  var app, cradle, db, express, markdown, md, wikiPage;

  express = require('express');

  cradle = require('cradle');

  markdown = require('markdown');

  db = new cradle.Connection().database('sliderule');

  app = express.createServer(express.logger(), express.static(__dirname + '/static'), express.bodyParser(), express.cookieParser(), express.session({
    secret: 'foo'
  }));

  app.set('view engine', 'jade');

  md = function(str) {
    return markdown.markdown.toHTML(str);
  };

  wikiPage = function(page, cb, errcb) {
    return db.get(page, function(err, doc) {
      if (err) {
        if (errcb) {
          return errcb(err);
        } else {
          if (typeof cb === 'function') {
            return cb(err);
          } else {
            return console.log(err);
          }
        }
      } else {
        if (typeof cb === 'function') {
          return cb(doc);
        } else {
          doc.content = md(doc.content);
          return cb.render('wiki', doc);
        }
      }
    });
  };

  app.get('/', function(req, res) {
    if (req.session.user) {
      return wikiPage('start', res);
    } else {
      return wikiPage('info', function(doc) {
        doc.layout = 'layout-form';
        return res.render('info', doc);
      });
    }
  });

  app.get('/login', function(req, res) {
    return res.render('login');
  });

  app.get('/more', function(req, res) {
    return wikiPage('more', function(doc) {
      doc.layout = 'layout-form';
      doc.content = md(doc.content);
      return res.render('more', doc);
    });
  });

  app.get('/wiki/:slug', function(req, res) {
    return wikiPage(req.params.slug, res);
  });

  app.get('/wiki/:slug/edit', function(req, res) {
    return wikiPage(req.params.slug, function(doc) {
      return res.render('wikiEdit', doc);
    });
  });

  app.post('/wiki/:slug', function(req, res) {
    return db.save(req.params.slug, {
      title: req.body.title,
      content: req.body.content
    }, function(err, doc) {
      return res.redirect('/wiki/' + req.params.slug);
    });
  });

  app.listen(3000);

}).call(this);
