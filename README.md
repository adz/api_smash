
## Smash - A Smarter Hash

The Smash class is a 'smarter' (or, alternatively, structured) hash. Built on top of
`Hashie::Dash`, `Smash` adds several features that make it useful for making objects
that represent an external api response. On top of [the base Hashie::Dash feature set](https://github.com/intridea/hashie/blob/master/lib/hashie/dash.rb),
Smash adds:

### Configuration of alternative names for fields

A feature useful for dealing with apis where they may have a `fullName` field in their api response
but you want to use `full_name`. Configurable by a simple  `:from` option on property declarations.

This importantly lets you deal with one format internally whilst automatically taking care of normalising
external data sources. More importantly, it also provides simple methods you can override to handle
a wide range of external schemes (e.g. always underscoring the field name).

### Configurable transformers

Essentially, any object (e.g. a lambda, a class or something else) that responds to `#call` can be used
to transform incoming data into a useable format. More importantly, your smash classes will also respond
to `#call` meaning they can intelligently be used as transformers for other classes, making complex / nested
objects simple and declarative.

Using it on a property is as simple as passing a `:transformer` option with the `#call`-able object
as the value.

### A well defined (and documented) api

Making it possible for you to hook in at multiple stages to further specialise your Smash objects for
specific API use cases.

## Contributors

API Smith was written by [Darcy Laycock](http://github.com/sutto), and [Steve Webb](http://github.com/swebb)
from [The Frontier Group](http://github.com/thefrontiergroup), as part of a bigger project with [Filter Squad](http://github.com/filtersquad).

This 'Smash' library was extracted from it.


## Contributing

We encourage all community contributions. Keeping this in mind, please follow these general guidelines when contributing:

* Fork the project
* Create a topic branch for what you’re working on (git checkout -b awesome_feature)
* Commit away, push that up (git push your\_remote awesome\_feature)
* Create a new GitHub Issue with the commit, asking for review. Alternatively, send a pull request with details of what you added.
* Once it’s accepted, if you want access to the core repository feel free to ask! Otherwise, you can continue to hack away in your own fork.

Other than that, our guidelines very closely match the GemCutter guidelines [here](http://wiki.github.com/qrush/gemcutter/contribution-guidelines).

(Thanks to [GemCutter](http://wiki.github.com/qrush/gemcutter/) for the contribution guide)

## License

API Smith is released under the MIT License (see the [license file](LICENSE)) and is
copyright Filter Squad, 2011.  Therefore so is 'Smash'.