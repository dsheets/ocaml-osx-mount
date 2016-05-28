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

module C(F: Cstubs.Types.TYPE) = struct

  module Fsstat_flags = struct
    type t = int

    let t = F.int

    let mnt_nowait = F.constant "MNT_NOWAIT" t
    let mnt_wait   = F.constant "MNT_WAIT" t
    let mnt_dwait  = F.constant "MNT_DWAIT" t
  end

  module Fsid = struct
    type t

    let t : t Ctypes_static.structure F.typ = F.structure "fsid"

    let val_ = F.field t "val" F.(array 2 int32_t)

    let () = F.seal t
  end

  module Statfs = struct
    type t

    let mfstypenamelen = 16 (*F.constant "MFSTYPENAMELEN" F.int*)
    let maxpathlen     = 1024 (*F.constant "MAXPATHLEN" F.int*)

    let t : t Ctypes_static.structure F.typ = F.structure "statfs"

    let bsize  = F.field t "f_bsize"  F.uint32_t
    let iosize = F.field t "f_iosize" F.int32_t
    let blocks = F.field t "f_blocks" F.uint64_t
    let bfree  = F.field t "f_bfree"  F.uint64_t
    let bavail = F.field t "f_bavail" F.uint64_t
    let files  = F.field t "f_files"  F.uint64_t
    let ffree  = F.field t "f_ffree"  F.uint64_t
    let fsid   = F.field t "f_fsid"   Fsid.t
    let owner  = F.field t "f_owner"  F.int
    let type_  = F.field t "f_type"   F.uint32_t
    let flags  = F.field t "f_flags"  F.uint32_t
    let fssubtype   = F.field t "f_fssubtype"   F.uint32_t
    let fstypename  = F.field t "f_fstypename"  F.(array mfstypenamelen char)
    let mntonname   = F.field t "f_mntonname"   F.(array maxpathlen char)
    let mntfromname = F.field t "f_mntfromname" F.(array maxpathlen char)

    let () = F.seal t
  end

end
