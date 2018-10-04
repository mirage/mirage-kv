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

type error = [
  | `Not_found  of string
  | `Is_a_tree  of string
  | `Not_a_tree of string
]
(** The type for errors. *)

val pp_error: error Fmt.t
(** [pp_error] is the pretty-printer for errors. *)

module Path: sig

  type t
  (** The type for paths. *)

  val v : string -> t
  (** [v s] is the string [s] as a path. *)

  val add_seg : t -> string -> t
  (** [add_seg t s] is the path [t/s] *)

  val ( / ) : t -> string -> t
  (** [t / x] is [add_seg t x]. *)

  val append : t -> t -> t
  (** [append x y] is the path [x / y]. *)

  val ( // ) : t -> t -> t
  (** [x // y] is [append x y]. *)

  val segs : t-> string list
  (** [segs t] is [t]'s list of segments. *)

  val basename : t -> string
  (** [basename t] is the last non-empty segment of [t]. *)

  val parent : t -> t
  (** [parent t] is a directory path that contains [t]. *)

  val compare : t-> t -> int
  (** The comparison function for paths. *)

  val equal : t -> t -> bool
  (** The equality function for paths. *)

  val pp : t Fmt.t
  (** The pretty printer for paths. *)

  val to_string: t -> string
  (** [to_string] is [Fmt.to_to_string pp]. *)

  val get_ext : t -> string
  (** [get_ext t] is [t]'s basename file extension. *)

  val has_ext : string -> t -> bool
  (** [has_ext e t] is [true] iff [get_ext t = e] *)

  val add_ext : string -> t -> t
  (** [add_ext e t] is [t] with the string [e] concatenated to [t]'s
     basename. *)

  val rem_ext : t -> t
  (** [rem_ext t] is [t] with the extension of [t]'s basename
     removed. *)

  val set_ext : string -> t -> t
  (** [set_ext e t] is [add_ext e (rem_ext t)]. *)

  val ( + ) : t -> string -> t
  (** [t + e] is [add_ext e t]. *)

end

type path = Path.t
(** The type for store paths. *)

module type RO = sig

  (** {1 Read-only, key-value stores} *)

  (** MirageOS read-only key-value stores are read-only tree-like structures
      holding buffers on their leaves. The functions in [RO] allow to distinguish
      between intermediate and leafs nodes. *)

  type nonrec error = private [> error]
  (** The type for errors. *)

  val pp_error: error Fmt.t
  (** [pp_error] is the pretty-printer for errors. *)

  include Mirage_device.S

  type buffer
  (** The type for memory buffers.*)

  val mem: t -> path -> (bool, error) result io
  (** [mem t p] is [true] iff a buffer is bound t [p] in [t]. *)

  val mem_tree: t -> path -> bool io
  (** [mem_tree t p] is [true] iff there exists a tree bound the path
     [p]. This means there exists a buffer bound to a path [p'] in
     [t], such that [p'] is a prefix of [p]. *)

 val get: t -> ?off:int64 -> ?len:int64 -> path -> (buffer, error) result io
  (** [get t ?off ?len p] is a view of the buffer bound to [p] in [t].
     By default, [off] is 0 and [len] is the length of the buffer less
     [off]. *)

 val kind: t -> path -> [`Buffer | `Tree] option io
  (** [kind t p] is [Some `Buffer] if [p] is bound to a buffer in [t],
     [Some `Tree] if [p] is a prefix of the valid key in [t] and
     [None] if no key with that prefix exists in [t]. *)

  val list: t -> path -> (string * [`Buffer | `Tree]) list io
  (** [list t p] is the list of entries (with their kind) in the tree
     bound to [p]. *)

  val size: t -> path -> (int64, error) result io
  (** [size t p] is the size of the buffer bound to [p] in [t]. *)

  val mtime: t -> path -> (int64, error) result io
  (** [mtime t p] is the last time the value bound to [p] in [t] has
     been modified. *)

  val digest: t -> path -> (string, error) result io
  (** [digest t p] is the digest of the value bound to [p] int [t]. *)

end

type write_error = error

module type RW = sig

  include RO

  type nonrec write_error = private [> write_error]
  (** The type for write errors. *)

  val pp_write_error: write_error Fmt.t
  (** The pretty-printer for [pp_write_error]. *)

  val set: t ->  ?off:int64 -> ?len:int64 -> path -> buffer ->
    (unit, write_error) result io
  (** [set t p v] adds the binding [p -> v] to [t]. *)

  val remove: t -> path -> (unit, write_error) result io
  (** [remove t p] remove binding to [p] in [t]. If [p] was bound to a
     tree, the full tree will be removed. *)

end
