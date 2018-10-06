(*
 * Copyright (c) 2011-2015 Anil Madhavapeddy <anil@recoil.org>
 * Copyright (c) 2013-2015 Thomas Gazagnaire <thomas@gazagnaire.org>
 * Copyright (c) 2013      Citrix Systems Inc
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *)

(** MirageOS signatures for key/value devices

    {e %%VERSION%% } *)

(** {1 Mirage_kv} *)

(** MirageOS key-value stores are nested dictionaries, associating
   structured {{!Key}keys} to either dictionaries or values. *)

type error = [
  | `Not_found           of string (** key not found *)
  | `Dictionary_expected of string (** key does not refer to a dictionary. *)
  | `Value_expected      of string (** key does not refer to a value. *)
]
(** The type for errors. *)

val pp_error: error Fmt.t
(** [pp_error] is the pretty-printer for errors. *)

module Key: sig

  (** {1 Structured keys} *)

  type t
  (** The type for structured keys. *)

  val empty: t
  (** [empty] is the empty key. It refers to the top-level
     dictionary. *)

  val v : string -> t
  (** [v s] is the string [s] as a key. A key ["/foo/bar"] is
     decomposed into the segments ["foo"] and ["bar"]. The initial
     ["/"] is always ignored so ["foo/bar"] and ["/foo/bar"] are
     equal. *)

  val add : t -> string -> t
  (** [add t s] is the concatenated key [t/s]. Raise
     [Invalid_argument] if [s] contains ["/"]. *)

  val ( / ) : t -> string -> t
  (** [t / x] is [add t x]. *)

  val append : t -> t -> t
  (** [append x y] is the concatenated key [x/y]. *)

  val ( // ) : t -> t -> t
  (** [x // y] is [append x y]. *)

  val segments : t-> string list
  (** [segments t] is [t]'s list of segments. *)

  val basename : t -> string
  (** [basename t] is the last segment of [t]. [basename empty] is
     the empty string [""]. *)

  val parent : t -> t
  (** [parent t] is the key without the last segment. [parent empty]
     is [empty].

      For any [t], the invariant have [parent t / basename t] is [t].
     *)

  val compare : t-> t -> int
  (** The comparison function for keys. *)

  val equal : t -> t -> bool
  (** The equality function for keys. *)

  val pp : t Fmt.t
  (** The pretty printer for keys. *)

  val to_string: t -> string
  (** [to_string t] is the string representation of [t]. ["/"] is used
     as separator between segements and it always starts with
     ["/"]. *)

end

type key = Key.t
(** The type for keys. *)

module type RO = sig

  (** {1 Read-only key-value stores} *)

  type nonrec error = private [> error]
  (** The type for errors. *)

  val pp_error: error Fmt.t
  (** [pp_error] is the pretty-printer for errors. *)

  include Mirage_device.S

  type value
  (** The type for values. *)

 val exists: t -> key -> ([`Value | `Dictionary], error) result io
 (** [exists t k] is [Some `Value] if [k] is bound to a value in [t],
    [Some `Dictionary] if [k] is a prefix of a valid key in [t] and
    [None] if no key with that prefix exists in [t]. *)

 val get: t -> key -> (value, error) result io
 (** [get t k] is the value bound to [k] in [t]. *)

  val list: t -> key -> ((string * [`Value | `Dictionary]) list, error) result io
  (** [list t k] is the list of entries and their types in the
     dictionary referenced by [k] in [t]. *)

  val last_modified: t -> key -> (int * int64, error) result io
  (** [last_modified t k] is the last time the value bound to [k] in
     [t] has been modified.

      The modification time [(d, ps)] is a span for the signed POSIX
     picosecond span [d] * 86_400e12 + [ps]. [d] is a signed number of
     POSIX days and [ps] a number of picoseconds in the range
     \[[0];[86_399_999_999_999_999L]\].

      When the value bound to [k] is a dictionary, the modification
     time is the latest modification of all entries in that
     dictionary.  *)

  val digest: t -> key -> (string, error) result io
  (** [digest t k] is the unique digest of the value bound to [k] in
     [t].

      When the value bound to [k] is a dictionary, the digest is a
     unique and deterministic digest of its entries. *)

end

type write_error = [ error | `No_space ]

module type RW = sig

  include RO

  type nonrec write_error = private [> write_error]
  (** The type for write errors. *)

  val pp_write_error: write_error Fmt.t
  (** The pretty-printer for [pp_write_error]. *)

  val set: t -> key -> value -> (unit, write_error) result io
  (** [set t k v] replaces the binding [k -> v] in [t]. *)

  val remove: t -> key -> (unit, write_error) result io
  (** [remove t k] removes any binding of [k] in [t]. If [k] was bound
     to a dictionary, the full dictionary will be removed. *)

end
