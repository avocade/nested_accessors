NestedAccessors
==============

This class lets you quickly add serialized, nested hash accessors in ActiveRecord
model objects, using regular `text` database columns.

```ruby
class Person < ActiveRecord::Base
  include NestedAccessors

  nested_accessor :info, [ :name, :phone ]
end
```

This would synthesize accessors to the `name` and `phone` properties contained
in the `info` hash.

```ruby
foo = Foo.new
foo.name = "bar"
foo.phone = "+46-123-45678"
foo.info #=> { "name" => "bar", "phone" => "+46-123-45678" }
```

If we want just a single `name` accessor we can remove the array:

```ruby
nested_accessor :info, :name
```


Installation
------------

- Add the gem to your `Gemfile`:

        source :rubygems
        gem 'nested_accessors', :git => 'git@github.com:avocade/nested_accessors.git'

- Run `bundle install`


Dependencies
------------

Requires `ActiveRecord` for the `serialize` class method. _(To be
reconsidered.)_


Nested hash
------------

You can nest accessors one level deep. To add more than one
nested hash accessor to `address` we specify `street` and `city`
inside an array.

```ruby
nested_accessor :info, address: [ :street, :city ]
```

This gives:

```ruby
object.address_street  # these two are nested inside the "address" hash
object.address_city
```

To just specify just one accessor, eg `address[street]`, we can simplify:

```ruby
nested_accessor :info, address: street
```

**Note**: The hash keys are always strings, never symbols. This is for
consistency of input/output.


Testing
-------

Run the `minitest` specs using:

    ruby nested_accessor_spec.rb


TODO
-----

- Extract as a ruby gem for rails `active_record` models
- Create object wrappers for each nested hash, so can get accessors like `person.address.street` for `person[address][street]`
- Add two-level nesting, eg `foo[bar][name][surname]`
- Array with nested Hash objects inside, eg `foo[bar][1][name]`
- Perhaps switch convention to always use symbolic keys instead of
stringified keys, so can use new ruby 1.9 hash syntax:

        foo.info = { name: "Anders" }
        foo.info[:name]

- Add typed arguments for each accessor (defaults to `String`)

        nested_accessor :info, phone: Integer

Author
------

Oskar Boethius Lissheim is a Product Designer and iOS &amp; Ruby on Rails developer. He currently lives in Gothenburg, Sweden.

You can reach him on App.net at
[@avocade](http://alpha.app.net/avocade), or
[Twitter](http://twitter.com/avocade).


License
-------

This code is offered under the MIT License.

Copyright &copy; 2012 Oskar Boethius Lissheim.

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
