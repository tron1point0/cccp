express = require 'express'
cradle = require 'cradle'
md = require('node-markdown').Markdown
db = new(cradle.Connection)().database 'sliderule'
app = express.createServer()

app.use express.static __dirname + '/static'
app.use express.bodyParser()
app.set 'view engine', 'jade'

showPage = (page,res) ->
    db.get page, (err,doc) ->
        if err
            res.render 'error',
                content: err
                title: 'Oops.'
        else
            doc.content = md doc.content
            res.render 'wiki', doc

app.get '/', (req,res) ->
    showPage 'start',res

app.get '/wiki/:slug', (req,res) ->
    showPage req.params.slug,res

app.get '/wiki/:slug/edit', (req,res) ->
    db.get req.params.slug, (err,doc) ->
        if err
            res.render 'error'
                content: err
                title: 'Oops.'
        else
            res.render 'wikiEdit', doc

app.post '/wiki/:slug', (req,res) ->
    db.save req.params.slug, {
        title: req.body.title
        content: req.body.content
    }, (err,doc) ->
        res.redirect '/wiki/'+req.params.slug

app.listen 3000
