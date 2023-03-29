### v6.1.1 (2023-03-29)

* Leave it up to implementations how to interpret `last_modified` for
  dictionaries, or even not implement it (then returning ``Error
  (`Value_expected _)``. The previous definition was not well founded when the
  dictionary doesn't contain any values directly, and some implementations
  implements `last_modified` differently from the description on dictionaries.
  (reported in #41, fixed in #42 by @reynir)
* Leave it up to implemetations how to interpret `digest` for dictionaries,
  or even not implement it (returning ``Error (`Value_expected _)``.
  (reported mirage/ocaml-tar#111, fixed in #43 by @reynir)

### v6.1.0 (2023-01-31)

* Mirage_kv.Key.add now raises Invalid_argument (instead of Failure). Document
  that it raises (#40 @reynir)

### v6.0.1 (2022-12-15)

* Specify in RO.list that the returned list consists of keys being absolute, and
  kinds (#38 #39 @reynir @hannesm)
* BREAKING: Before 6.0.0, the return type of RO.list consisted of a string and
  kind list, where the string was relative. Now it is absolute.

### v6.0.0 (2022-12-12)

* Use ptime directly for RO.last_modified, instead of the int * int64 pair
  (#34)
* Add RW.allocate to allocate a key and fill it with zero bytes (#34)
* RO.list: return Key.t instead of string (#37, fixes #33)
* Introduce a custom error for RW.rename with a source which is a prefix of
  destination (#37, fixes #31)
* Use Optint.Int63.t for RO.size, RO.get_partial, RO.set_partial (#37, fixes #32)
* Remove RW.batch (#37, fixes #29 #36, discussed at the MirageOS meeting in
  November, and on the mirageos-devel mailing list in January 2022)
* Key.pp: escape the entire string, not individual fragments (#35)

### v5.0.0 (2022-09-07)

* Add `get_partial` and `size` to the RO interface (@palainp #28, review by
  @yomimono @hannesm)
* Add `set_partial` and `rename` to the RW interface (@palainp #28, review by
  @yomimono @hannesm)
* Mirage_kv.Key.pp: escape binary keys (#30 @hannesm)

### v4.0.1 (2022-02-28)

* Return `/` for `parent /` and `basename /` (@yomimono, @talex5, #25)

### v4.0.0 (2021-11-15)

* Remove Mirage_kv_lwt module (#24 @hannesm)
* remove mirage-device dependency (#24 @hannesm)
* Adapt to fmt 0.8.7 dependency (#23 @MisterDA)

### v3.0.1 (2019-11-04)

* provide deprecated Mirage_kv_lwt for smooth transition (#21 @hannesm)

### v3.0.0 (2019-10-22)

* remove mirage-kv-lwt (#19 @hannesm)
* specialise mirage-kv on Lwt.t and value being string (#19 @hannesm)
* raise lower OCaml bound to 4.06.0 (#19 @hannesm)

### v2.0.0 (2019-02-24)

* Major revision of the `RO` signature:
 - values are of type `string`
 - keys are segments instead of a string
 - `read` is now named `get`, and does no longer take an offset and length
 - the new function `list` is provided
 - the new functions `last_modified` and `digest` are provided
* A module `Key` is provided with convenience functions to build keys
* An `RW` signature is provided, extending `RO` with
 - a function `set` to replace a value
 - a function `remove` to remove a key
 - `batch` to batch operations

### v1.1.1 (2017-06-29)

* Remove `open Result` statements (and drop support to 4.02)

### v1.1.0 (2017-05-26)

* Port to Jbuilder.

### v1.0.0 (2016-12-27)

* First release, import `V1.KV_RO` and `V1_LWT.KV_RO` from mirage-types.
