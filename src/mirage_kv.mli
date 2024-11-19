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

(** {2 Mirage_kv} *)

(** MirageOS key-value stores are nested dictionaries, associating
   structured {{!Key}keys} to either dictionaries or values. *)

module Key: sig

  (** {2 Structured keys} *)

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
  (** [add t s] is the concatenated key [t/s].

      @raise Invalid_argument if [s] contains ['/']. *)

  val ( / ) : t -> string -> t
  (** [t / x] is [add t x].

      @raise Invalid_argument if [s] contains ['/']. *)

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

type error = [
  | `Not_found           of key (** key not found *)
  | `Dictionary_expected of key (** key does not refer to a dictionary. *)
  | `Value_expected      of key (** key does not refer to a value. *)
]
(** The type for errors. *)

val pp_error: error Fmt.t
(** [pp_error] is the pretty-printer for errors. *)

module type RO = sig

  (** {2 Read-only key-value stores} *)

  type nonrec error = private [> error]
  (** The type for errors. *)

  val pp_error: error Fmt.t
  (** [pp_error] is the pretty-printer for errors. *)

  type t
  (** The type representing the internal state of the key-value store. *)

  val disconnect: t -> unit Lwt.t
  (** Disconnect from the key-value store. While this might take some time to
      complete, it can never result in an error. *)

  type key = Key.t
  (** The type for keys. *)

  val exists: t -> key -> ([`Value | `Dictionary] option, error) result Lwt.t
  (** [exists t k] is [Some `Value] if [k] is bound to a value in [t],
      [Some `Dictionary] if [k] is a prefix of a valid key in [t] and
      [None] if no key with that prefix exists in [t].

      {!exists} answers two questions: does the key exist and is it
      referring to a value or a dictionary.

      An error occurs when the underlying storage layer fails. *)

  val get: t -> key -> (string, error) result Lwt.t
  (** [get t k] is the value bound to [k] in [t].

      The result is [Error (`Value_expected k)] if [k] refers to a
      dictionary in [t]. *)

  val get_partial: t -> key -> offset:Optint.Int63.t -> length:int -> (string, error) result Lwt.t
  (** [get_partial t k ~offset ~length] is the [length] bytes wide value
     bound at [offset] of [k] in [t].

      If the size of [k] is less than [offset], [get_partial] returns an
     empty string.
      If the size of [k] is less than [offset]+[length], [get_partial]
     returns a short string.
      The result is [Error (`Value_expected k)] if [k] refers to a
     dictionary in [t]. *)

  val list: t -> key -> ((key * [`Value | `Dictionary]) list, error) result Lwt.t
  (** [list t k] is the list of entries and their types in the
     dictionary referenced by [k] in [t]. The returned keys are all absolute
     (i.e. [Key.add k entry]).

      The result is [Error (`Dictionary_expected k)] if [k] refers to a
     value in [t]. *)

  val last_modified: t -> key -> (Ptime.t, error) result Lwt.t
  (** [last_modified t k] is the last time the value bound to [k] in
     [t] has been modified.

      When the value bound to [k] is a dictionary, the implementation is free
      to decide how to compute a last modified timestamp, or return [Error
      (`Value_expected _)]. *)

  val digest: t -> key -> (string, error) result Lwt.t
  (** [digest t k] is the unique digest of the value bound to [k] in
      [t]. The digest uses all bits and is not expected to be printable. If
      desired, a conversion to hexadecimal encoding should be done.

      When the value bound to [k] is a dictionary, the implementation is
      allowed to return [Error (`Value_expected _)]. Otherwise, the [digest] is
      a unique and deterministic digest of its entries. *)

  val size: t -> key -> (Optint.Int63.t, error) result Lwt.t
  (** [size t k] is the size of [k] in [t]. *)


end

type write_error = [
  | error
  | `No_space (** No space left on the device. *)
  | `Rename_source_prefix of key * key (** The source is a prefix of destination in rename. *)
  | `Already_present of key (** The key is already present. *)
]

val pp_write_error: write_error Fmt.t
(** [pp_write_error] is the pretty-printer for write errors. *)

module type RW = sig

  (** {2 Read-write Stores} *)

  (** The functions {!set} and {!remove} will cause a flush in
     the underlying storage layer every time, which can degrade
     performance. *)

  include RO

  type nonrec write_error = private [> write_error]
  (** The type for write errors. *)

  val pp_write_error: write_error Fmt.t
  (** The pretty-printer for [pp_write_error]. *)

  val allocate : t -> key -> ?last_modified:Ptime.t -> Optint.Int63.t ->
    (unit, write_error) result Lwt.t
  (** [allocate t key ~last_modified size] allocates space for [key] in [t] with
      the provided [size] and [last_modified]. This is useful for e.g.
      append-only backends that could still use {!set_partial}. The data will
      be filled with 0. If [key] already exists, [Error (`Already_present key)]
      is returned. If there's not enough space, [Error `No_space] is returned.
  *)

  val set: t -> key -> string -> (unit, write_error) result Lwt.t
  (** [set t k v] replaces the binding [k -> v] in [t].

      Durability is guaranteed. *)

  val set_partial: t -> key -> offset:Optint.Int63.t -> string -> (unit, write_error) result Lwt.t
  (** [set_partial t k offset v] attempts to write [v] at [offset] in the
     value bound to [k] in [t].
      If [k] contains directories that do not exist, [set_partial] will
     attempt to create them.
      If the size of [k] is less than [offset], [set_partial] appends [v]
     at the end of [k].
      If the size of [k] is greater than [offset]+length of [v],
     [set_partial] leaves the last bytes of [k] unchanged.

      The result is [Error (`Value_expected k)] if [k] refers to a
     dictionary in [t]. *)

  val remove: t -> key -> (unit, write_error) result Lwt.t
  (** [remove t k] removes any binding of [k] in [t]. If [k] was bound
     to a dictionary, the full dictionary will be removed.

      Durability is guaranteed. *)

  val rename: t -> source:key -> dest:key -> (unit, write_error) result Lwt.t
  (** [rename t source dest] rename [source] to [dest] in [t].
      If [source] and [dest] are both bound to values in [t], [dest]
     is removed and the binding of [source] is moved to [dest].
      If [dest] is bound to a dictionary in [t], [source] is moved
     inside [dest]. If [source] is bound to a dictionary, the full
     dictionary is moved.

      The result is [Error (`Not_found source)] if [source] does not
     exists in [t].
      The result is [Error (`Value_expected source)] if [source] is
     bound to a dictionary in [t] and [dest] is bound to a value in [t].
      The result id [Error (`Rename_source_prefix (source, dest))] if [source]
     is a prefix of [dest], and [source] is a directory.
 *)
end
