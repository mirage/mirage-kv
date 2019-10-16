## mirage-kv — MirageOS signatures for key/value devices

mirage-kv provides the [Mirage_kv.RO][ro] and [Mirage_kv.RW][rw]
signatures the MirageOS key/value devices should implement. In addition, modules
specialized for use with Lwt and Async are provided where `io` is constrained to `Lwt.t`
or `Deferred.t` respectively, and `value` is constrained to `string`:

- [Mirage_kv_lwt.RO][ro-lwt], [Mirage_kv_lwt.RW][rw-lwt]
- [Mirage_kv_async.RO][ro-async], [Mirage_kv_async.RW][rw-async]

mirage-kv is distributed under the ISC license.

[ro]: https://mirage.github.io/mirage-kv/mirage-kv/Mirage_kv/module-type-RO/index.html
[rw]: https://mirage.github.io/mirage-kv/mirage-kv/Mirage_kv/module-type-RW/index.html
[ro-lwt]: https://mirage.github.io/mirage-kv/mirage-kv-lwt/Mirage_kv_lwt/index.html#module-type-RO
[rw-lwt]: https://mirage.github.io/mirage-kv/mirage-kv-lwt/Mirage_kv_lwt/index.html#module-type-RW
[ro-async]: https://mirage.github.io/mirage-kv/mirage-kv-async/Mirage_kv_async/index.html#module-type-RO
[rw-async]: https://mirage.github.io/mirage-kv/mirage-kv-async/Mirage_kv_async/index.html#module-type-RW

[![Build Status](https://travis-ci.org/mirage/mirage-kv.svg?branch=master)](https://travis-ci.org/mirage/mirage-kv)

## Installation

mirage-kv can be installed with `opam`:

    opam install mirage-kv

If you don't use `opam` consult the [`opam`](opam) file for build
instructions.

## Documentation

The documentation and API reference is generated from the source interfaces. API docs for
both [mirage-kv][doc-mirage-kv], [mirage-kv-lwt][doc-mirage-kv-lwt], and
[mirage-kv-async][doc-mirage-kv-async] can be consulted online or via `odig doc
mirage-kv`.

[doc-mirage-kv]: http://docs.mirage.io/mirage-kv/
[doc-mirage-kv-lwt]: http://docs.mirage.io/mirage-kv-lwt/
[doc-mirage-kv-async]: http://docs.mirage.io/mirage-kv-async/
