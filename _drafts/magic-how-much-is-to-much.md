# Python magic: How much is too much?

My latest pet project is [Flask-Webmachine](https://github.com/pwoolcoc/flask-webmachine.git),
my effort to build a [Webmachine](https://github.com/basho/webmachine.git)-like
system on top of the [Flask](https://github.com/pocoo/Flask.git)
micro-framework.

When I started the project, I decided that I wanted to give the user the
ability to map URIs to resources in a way that was very Flask-like.  I
imagined the user defining something like this:

    >>> from flask import Flask
    >>> from flaskext.webmachine import Webmachine
    >>>
    >>> DATABASE_URI = u'postgresql://user:pass@myhost.com:5432'
    >>>
    >>> app = Flask(__name__)
    >>> app.config.from_object(__name__)
    >>> wm = Webmachine(app)
    >>>
    >>> @wm.resource('/myresource')
    ... class MyResource(object):
    ...     pass
    >>>
    >>> app.run()
    app running at http://localhost:5000/

and getting a fully-functional, truly RESTful hypermedia API right out
of the box.

There are a couple parts to this that I thought were important.  First,
I wanted to be able to map URIs to resources similarly to how you
usually map URIs to handlers in vanilla Flask.  Not only would that
make the extension more "Flask-like," but it would hopefully be an
intuitive way, for people who might not know all the intricate details
about HTTP and Hypermedia, to build APIs that are very RESTful.

Second, I did not want to force the user to have to subclass some
`Resource` class in order to define a resource.  This is important to me
because it completes the Flask-like routing pattern of mapping a URIs to
a basic, native Python resource.  Though handlers in Flask are usually
functions, there is nothing I know of that would prevent some
non-function to be used, as long as the object was callable.  Allowing
classes unencumbered by subclasses to be used as resources means that
it's that much easier for someone to define resources in a way I might
not have thought about yet.

Unfortunately, in order to make this happen the way I want, we have to
add some functionality to the user's resources at some point.  So, I
chose to have the `Webmachine#resource` decorator perform some magic.

