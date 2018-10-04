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

type error = [
  | `Not_found  of string
  | `Is_a_tree  of string
  | `Not_a_tree of string
]

let pp_error ppf = function
  | `Not_found k  -> Fmt.pf ppf "Cannot find %s" k
  | `Is_a_tree k  -> Fmt.pf ppf "%s is a tree" k
  | `Not_a_tree k -> Fmt.pf ppf "%s is not a tree" k

module Path = struct

  type t = string list
  (* Store the path as a reverse list to optimise basename and (/)
     operations *)

  let v s = List.rev (String.split_on_char '/' s)
  let add_seg t v = v :: t
  let ( / ) = add_seg
  let append x y = y @ x
  let ( // ) = append
  let segs = List.rev
  let basename = List.hd
  let parent = List.tl
  let compare = compare
  let equal = (=)
  let pp ppf l = Fmt.(list ~sep:(unit "/") string) ppf (List.rev l)
  let to_string = Fmt.to_to_string pp

  let get_ext = function
    | []   -> ""
    | h::_ -> Filename.extension h

  let has_ext e = function
    | []   -> false
    | h::_ -> e = Filename.extension h

  let add_ext e = function
    | []   -> []
    | h::t -> (h ^ "." ^ e) :: t

  let rem_ext = function
    | []   -> []
    | h::t -> Filename.remove_extension h :: t

  let set_ext e t = add_ext e (rem_ext t)

  let ( + ) t e = add_ext e t

end

type path = Path.t

module type RO = sig
  type nonrec error = private [> error]
  val pp_error: error Fmt.t
  include Mirage_device.S
  type buffer
  val mem: t -> path -> (bool, error) result io
  val mem_tree: t -> path -> bool io
  val get: t -> ?off:int64 -> ?len:int64 -> path -> (buffer, error) result io
  val kind: t -> path -> [`Buffer | `Tree] option io
  val list: t -> path -> (string * [`Buffer | `Tree]) list io
  val size: t -> path -> (int64, error) result io
  val mtime: t -> path -> (int64, error) result io
  val digest: t -> path -> (string, error) result io
end

type write_error = error

module type RW = sig
  include RO
  type nonrec write_error = private [> write_error]
  val pp_write_error: write_error Fmt.t
  val set: t -> ?off:int64 -> ?len:int64 -> path -> buffer ->
    (unit, write_error) result io
  val remove: t -> path -> (unit, write_error) result io
end
