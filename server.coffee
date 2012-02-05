express = require 'express'
cradle = require 'cradle'
markdown = require 'markdown'

db = new(cradle.Connection)().database 'sliderule'
app = express.createServer(
    express.logger(),
    express.static(__dirname + '/static'),
    express.bodyParser(),
    express.cookieParser(),
    express.session(secret: 'foo')
)

app.set 'view engine', 'jade'

md = (str) -> markdown.markdown.toHTML(str)

wikiPage = (page,cb,errcb) ->
    db.get page, (err,doc) ->
        if err
            if errcb
                errcb(err)
            else
                if typeof cb == 'function'
                    cb(err)
                else
                    console.log err
        else
            if typeof cb == 'function'
                cb(doc)
            else
                doc.content = md doc.content
                cb.render 'wiki', doc

app.get '/', (req,res) ->
    if req.session.user
        wikiPage 'start', res
    else
        wikiPage 'info', (doc) ->
            doc.layout = 'layout-form'
            res.render 'info', doc

app.get '/login', (req,res) ->
    res.render 'login'

app.get '/more', (req,res) ->
    wikiPage 'more', (doc) ->
        doc.layout = 'layout-form'
        doc.content = md doc.content
        res.render 'more', doc

app.get '/wiki/:slug', (req,res) ->
    wikiPage req.params.slug, res

app.get '/wiki/:slug/edit', (req,res) ->
    wikiPage req.params.slug, (doc) ->
        res.render 'wikiEdit', doc

app.post '/wiki/:slug', (req,res) ->
    db.save req.params.slug, {
        title: req.body.title
        content: req.body.content
    }, (err,doc) ->
        res.redirect '/wiki/'+req.params.slug

app.listen 3000
