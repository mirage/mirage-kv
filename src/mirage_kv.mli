(*
 * Copyright (c) 2018      Stefanie Schirmer, Hannes Mehnert
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

type error = [`Unknown_key of string]
(** The type for errors. *)

val pp_error: error Fmt.t
(** [pp_error] is the pretty-printer for errors. *)

module type RO = sig

  type error = private [> `Unknown_key of string]
  (** The type for errors. *)

  val pp_error: error Fmt.t
  (** [pp_error] is the pretty-printer for errors. *)

  include Mirage_device.S

  type buffer
  (** The type for memory buffer.*)

  val read: t -> string -> ?offset:int64 -> ?length:int64 ->
    (buffer, error) result io
  (** [read t key ~offset ~length] reads up to [length] bytes from the value
      associated with [key] starting at [offset] (defaults to 0).  If [length]
      is not given, the end of value is used.  If [offset + length] is longer
      than the [value], we return what we can. *)

  val mem: t -> string -> (bool, error) result io
  (** [mem t key] returns [true] if a value is set for [key] in [t],
      and [false] if not so. *)

  val size: t -> string -> (int64, error) result io
  (** Get the value size. *)

end
