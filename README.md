# Type-Safe Client Side Routing in Miso
This is an example of using servant-style routing in Miso. The example was
written to mimic [React Router's basic
example](https://reactrouter.com/web/example/basic).

# Documenation
The following links were consulted when figuring out what all the pieces meant
- ["Transition application" Example from Miso README](https://github.com/dmjio/miso#transition-application)
- ["Router" Example from Miso README](https://github.com/dmjio/miso/blob/master/examples/router/Main.hs)
- [The Transition Monad](https://haddocks.haskell-miso.org/Miso-Types.html)
- [TypeSafe Links in Servant](https://hackage.haskell.org/package/servant-0.18/docs/Servant-Links.html)

# Setup
To use this repo as-is, you'll need nix installed, since I use the same set up
recommended in the official readme [here](https://github.com/dmjio/miso#nix).

# Running Locally
If you attempt to open the index.html file directly from the `result` directory,
you might see security warnings and notice that the app doesn't behave properly.
YOu can avoid this by running an http server. A quick way to do so on a unix
machine is to `cd` into `result/bin/miso-routing.jsexe` and run `python -m
http.server` (Python  3).
