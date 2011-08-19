from web.template import CompiledTemplate, ForLoop, TemplateResult


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
    extend_([u'<!doctype html>\n'])
    extend_([u'\n'])
    extend_([u'<body>\n'])
    extend_([u'...\n'])
    extend_([u'\n'])
    extend_([escape_(context.user.nickname(), True), u'\n'])
    extend_([u'</body>\n'])
    extend_([u'\n'])
    extend_([u'</html>\n'])

    return self

index = CompiledTemplate(index, 'templates/index.html')
join_ = index._join; escape_ = index._escape

# coding: utf-8
def tree (context):
    __lineoffset__ = -4
    loop = ForLoop()
    self = TemplateResult(); extend_ = self.extend
    extend_([u'<!doctype html>\n'])
    extend_([u'\n'])
    extend_([u'<body>\n'])
    extend_([u'\n'])
    extend_([u'<div>You are ', escape_(context.user, True), u'</div>\n'])
    extend_([u'<a href="/"></a>\n'])
    extend_([u'\n'])
    extend_([u'\n'])
    extend_([u'\n'])
    extend_([u'</body>\n'])
    extend_([u'</html>\n'])

    return self

tree = CompiledTemplate(tree, 'templates/tree.html')
join_ = tree._join; escape_ = tree._escape

