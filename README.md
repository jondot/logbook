<img src="https://raw.github.com/jondot/logbook/master/resources/logbook.png" style="width:136px"/><br/>
Logbook allows you to record memories easily from your command line into
virtual book(s). Books are simply private Github Gists (backend is
replaceable).


It is heavily inspired from its pythonish friend, http://maebert.github.com/jrnl.

I built it because I love Ruby, it was easy enough, and I really loved
the idea of storing as Gists as opposed to plain files.



# Usage

For brevity's sake, the Logbook gem name and executable is `lg`.

    $ gem install lg
    $ lg


If you want private Gists attached to your user (you most probably
want that), make sure to set your Github credentials as environment
variables, example:

    $ export GITHUB_USER=youruser
    $ export GITHUB_PASSWORD=yourpw

Now we need to make a first `book` and start `add`ing into it.  

## Setting up a book

Create a new book with the `lg book` command. You can give it a
cover, in this case `The Wizzard of Oz`.

    $ lg book The Wizzard of Oz


## Adding things

Simply say 'lg add' and your memory in a short sentence.

    $ lg add just wrote the logbook gem README

You might find it convenient to specify when a thing happend explicitly,
just make sure to specify a natural date such as `yesterday` separated
by a colon `:`. Translation done with the `chronic` gem.

    $ lg add yesterday: wrote the logbook gem README


## More

You can safely skip this if that's all what you're looking for.

## Switching books

Switch between books, when you know what you want, you can explicitly
specify the ID.

    $ lg book book-id

Or pick from a menu, leaving arguments blank:

    $ lg book
    1    The Wizzard of Oz   deadbeef0aef
    ...
    Pick one: 1


## Listing things

Say `lg all` when you want to see everything you've recorded.




# Philosophy

Command line is awesome. Its fast, and you feel it when you're less
dependent on your mouse for your development work (e.g. VIM).  

You should just Alt/Command-Tab, write a line and go back working.  

You should be expected to remember at most one commands (pitfall of success) to do actual work. Seriously, [focus](http://ezliu.com/focus/).


## There's no search like in jrnl

Feature slim. Use gist search for that. True, its limited, but as of now, I believe
Github are working on improving that.  

In actuallity, `jrnl`'s search loads all of your entries to memory and
performs search on an in-memory structure.  
If the need arises, it should be dead easy to
make *that* kind of search in `logbook`.

## There's no delete/modify

Again, feature slim. If you were using a real logbook, you'd
just cross the bad entry. It will still be there.  
If you must, you can always use the gist interface for that.  

## There's no analytics, let me reap added value from my work!

Actually, a gist entry is a Git repository.  
The modeling on-top-of a
Gist was done intentionally. Clone your book and
treat it like a Git repo.

From there, you can script against git and/or run countless analysis tools on your repository.

# Developers

Set up development: `git clone`, `bundle install`, `bundle exec guard start`.  
Build/install a development snapshot: `rake build`, `rake install`.

Credit: Thanks to @defunkt!. I've included and heavily modified a version of [defunkt/gist](https://github.com/defunkt/gist) in this project.  



# Contributing

Fork, implement, add tests, pull request, get my everlasting thanks and a respectable place here :).


# Copyright

Copyright (c) 2012 [Dotan Nahum](http://gplus.to/dotan) [@jondot](http://twitter.com/jondot). See MIT-LICENSE for further details.


