from web.template import CompiledTemplate, ForLoop, TemplateResult


# coding: utf-8
def base (content):
    __lineoffset__ = -4
    loop = ForLoop()
    self = TemplateResult(); extend_ = self.extend
    extend_([u'<!doctype html>\n'])
    extend_([u'<!-- paulirish.com/2008/conditional-stylesheets-vs-css-hacks-answer-neither/ -->\n'])
    extend_([u'<!--[if lt IE 7]> <html class="no-js ie6 oldie" lang="en"> <![endif]-->\n'])
    extend_([u'<!--[if IE 7]>    <html class="no-js ie7 oldie" lang="en"> <![endif]-->\n'])
    extend_([u'<!--[if IE 8]>    <html class="no-js ie8 oldie" lang="en"> <![endif]-->\n'])
    extend_([u'<!--[if gt IE 8]><!--> <html class="no-js" lang="en"> <!--<![endif]-->\n'])
    extend_([u'<head>\n'])
    extend_([u'  <meta charset="utf-8">\n'])
    extend_([u'  <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">\n'])
    extend_([u'\n'])
    extend_([u'  <title>TreeOrg - ', escape_(content.title, True), u'</title>\n'])
    extend_([u'  <meta name="description" content="">\n'])
    extend_([u'  <meta name="author" content="">\n'])
    extend_([u'\n'])
    extend_([u'  <meta name="viewport" content="width=device-width,initial-scale=1">\n'])
    extend_([u'\n'])
    extend_([u"  <link href='http://fonts.googleapis.com/css?family=Open+Sans' rel='stylesheet' type='text/css'>\n"])
    extend_([u'  <link rel="stylesheet" href="css/style.css">\n'])
    extend_([u'\n'])
    extend_([u'  <link rel="shortcut icon" href="/favicon.gif" />\n'])
    extend_([u'  <script src="js/libs/modernizr-2.0.6.min.js"></script>\n'])
    extend_([u'</head>\n'])
    extend_([u'\n'])
    extend_([u'<body>\n'])
    extend_([u'        <header>\n'])
    extend_([u'        <h1>treeorg</h1>\n'])
    extend_([u'        </header>\n'])
    extend_([u'        ', escape_(content, False), u'\n'])
    extend_([u'\n'])
    extend_([u'  <!-- JavaScript at the bottom for fast page loading -->\n'])
    extend_([u'\n'])
    extend_([u"  <!-- Grab Google CDN's jQuery, with a protocol relative URL; fall back to local if offline -->\n"])
    extend_([u'  <script src="//ajax.googleapis.com/ajax/libs/jquery/1.6.2/jquery.min.js"></script>\n'])
    extend_([u'  <script src="//ajax.googleapis.com/ajax/libs/jqueryui/1.8.16/jquery-ui.js"></script>\n'])
    extend_([u'  <script>window.jQuery || document.write(\'<script src="js/libs/jquery-1.6.2.min.js"><\\/script>\')</script>\n'])
    extend_([u'\n'])
    extend_([u'  <!--\n'])
    extend_([u'  <script src="http://ajax.cdnjs.com/ajax/libs/underscore.js/1.1.6/underscore-min.js"></script> \n'])
    extend_([u'  <script src="http://ajax.cdnjs.com/ajax/libs/backbone.js/0.3.3/backbone-min.js"></script>\n'])
    extend_([u'  -->\n'])
    extend_([u'  <script src="/js/underscore.js"></script>\n'])
    extend_([u'  <script src="/js/backbone.js"></script>\n'])
    extend_([u'\n'])
    extend_([u'\n'])
    extend_([u'  <!-- TODO: conditional load\n'])
    extend_([u'  <script src="/js/libs/backbone-min.js"></script>\n'])
    extend_([u'  <script src="/js/libs/underscore-min.js"></script>\n'])
    extend_([u'  -->\n'])
    extend_([u'\n'])
    extend_([u'\n'])
    extend_([u'  <!-- scripts concatenated and minified via ant build script-->\n'])
    extend_([u'  <script defer src="js/plugins.js"></script>\n'])
    extend_([u'  <script defer src="js/main.js"></script>\n'])
    extend_([u'  <!-- end scripts-->\n'])
    extend_([u'\n'])
    extend_([u'        \n'])
    extend_([u"  <!-- Change UA-XXXXX-X to be your site's ID -->\n"])
    extend_([u'  <script>\n'])
    extend_([u"    window._gaq = [['_setAccount','UAXXXXXXXX1'],['_trackPageview'],['_trackPageLoadTime']];\n"])
    extend_([u'    Modernizr.load({\n'])
    extend_([u"      load: ('https:' == location.protocol ? '//ssl' : '//www') + '.google-analytics.com/ga.js'\n"])
    extend_([u'    });\n'])
    extend_([u'  </script>\n'])
    extend_([u'\n'])
    extend_([u'\n'])
    extend_([u'  <!-- Prompt IE 6 users to install Chrome Frame. Remove this if you want to support IE 6.\n'])
    extend_([u'       chromium.org/developers/how-tos/chrome-frame-getting-started -->\n'])
    extend_([u'  <!--[if lt IE 7 ]>\n'])
    extend_([u'    <script src="//ajax.googleapis.com/ajax/libs/chrome-frame/1.0.3/CFInstall.min.js"></script>\n'])
    extend_([u"    <script>window.attachEvent('onload',function(){CFInstall.check({mode:'overlay'})})</script>\n"])
    extend_([u'  <![endif]-->\n'])
    extend_([u'  \n'])
    extend_([u'</body>\n'])
    extend_([u'</html>\n'])

    return self

base = CompiledTemplate(base, 'templates/base.html')
join_ = base._join; escape_ = base._escape

# coding: utf-8
def nodes():
    __lineoffset__ = -5
    loop = ForLoop()
    self = TemplateResult(); extend_ = self.extend
    extend_([u'<!doctype html>\n'])
    extend_([u'\n'])
    extend_([u'<body>\n'])
    extend_([u'\n'])
    extend_([u'<div>You</div>\n'])
    extend_([u'<a href="/"></a>\n'])
    extend_([u'\n'])
    extend_([u'\n'])
    extend_([u'</body>\n'])
    extend_([u'</html>\n'])

    return self

nodes = CompiledTemplate(nodes, 'templates/nodes.html')
join_ = nodes._join; escape_ = nodes._escape

# coding: utf-8
def index (context):
    __lineoffset__ = -4
    loop = ForLoop()
    self = TemplateResult(); extend_ = self.extend
    extend_([u'\n'])
    self['title'] = join_(u'Explore the Tree')
    extend_([u'\n'])
    extend_([u'<div id="container">\n'])
    extend_([u'\n'])
    extend_([u'</div>\n'])

    return self

index = CompiledTemplate(index, 'templates/index.html')
join_ = index._join; escape_ = index._escape

# coding: utf-8
def tree (context):
    __lineoffset__ = -4
    loop = ForLoop()
    self = TemplateResult(); extend_ = self.extend
    extend_([u'\n'])
    self['title'] = join_(u'Explore the Tree')
    extend_([u'\n'])
    extend_([u'<div>You are ', escape_(context.user, True), u'</div>\n'])
    extend_([u'<a href="/">a</a>\n'])
    extend_([u'\n'])

    return self

tree = CompiledTemplate(tree, 'templates/tree.html')
join_ = tree._join; escape_ = tree._escape

