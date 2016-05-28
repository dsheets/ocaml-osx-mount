(*
 * Copyright (c) 2016 David Sheets <dsheets@docker.com>
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
 *
 *)

open Ctypes

module Type = Osx_mount_types.C(Osx_mount_types_detected)

module C(F: Cstubs.FOREIGN) = struct

  module Fsstat_flags = struct
    type t =
      | NOWAIT
      | WAIT
      | DWAIT

    let of_int i = Type.Fsstat_flags.(
      if i = mnt_nowait
      then NOWAIT
      else if i = mnt_wait
      then WAIT
      else if i = mnt_dwait
      then DWAIT
      else failwith ("unknown fsstat flag "^string_of_int i)
    )

    let to_int = Type.Fsstat_flags.(function
      | NOWAIT -> mnt_nowait
      | WAIT -> mnt_wait
      | DWAIT -> mnt_dwait
    )

    let t = view ~read:of_int ~write:to_int int
  end
  
  let getmntinfo = F.foreign "osx_mount_getmntinfo"
      (ptr (ptr Type.Statfs.t) @-> Fsstat_flags.t @-> returning int)

  let statfs = F.foreign "osx_mount_statfs"
      (string @-> ptr Type.Statfs.t @-> returning int)
end
