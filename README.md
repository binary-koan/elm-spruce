# Spruce

A server-side framework for Elm.

**IMPORTANT: This is an experiment, and will remain so until mainline Elm development considers server-side development a sensible direction for Elm. Do not expect any kind of API stability, official releases, etc.**

With that out of the way ...

## How it works

Spruce is based around a routing tree inspired by [Roda](http://roda.jeremyevans.net/). Rather like the declarative approach to HTML that client-side Elm uses, Spruce works by defining routes and responses as plain old arrays and functions. For example, to render some text on a homepage and some different text at the `/hello` route, you would do this:

```elm
app : Server
app =
    server
        [ root [ text "Homepage!" ]
        , on "hello"
            [ is [ text "Hello page!" ] ]
        ]
```

The important things to note here are

* A `server` takes a list of "steps" (things to do). There are all sorts of steps which can be composed to build arbitrarily complex routes and responses
* The `root` step is executed if the request is for the root path, `/`
* Inside the `root` step, we use the `text` step to set the text of the response
* The `on` step filters based on a path fragment. In this case, we filter for the path `hello`, meaning any request for `/hello`
* Inside that step, we use `is` to match the path exactly (so we only respond to `/hello`, not `/hello/world`), and we use `text` to set the response just like in the root step

That works fine for purely static sites, but if we wanted a purely static site we wouldn't bother having a server. That's why the `onParam` and `withRequest` steps exist. Each takes a function which returns its own list of steps. In the `FakeAuth` example, `withRequest` is used to check whether the user is authorised. If they have the super-secret password in plaintext in the request URL, it lets them in by returning the project-related steps. If they don't, it returns a different set of steps to redirect them back to the homepage.

## Try it out

1. Make sure you have Node.js, Elm and [elm-github-install](https://github.com/gdotdesign/elm-github-install) available
2. Clone this repo and run `npm install` and `elm install`
3. Use `npm run example <name>` to run one of the examples (e.g. `npm run example Basic`)
