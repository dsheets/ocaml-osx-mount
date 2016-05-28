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

module Types = Osx_mount_types.C(Osx_mount_types_detected)
module C = Osx_mount_bindings.C(Osx_mount_generated)

module Statfs = struct
  type t = {
    bsize  : int;
    iosize : int;
    blocks : int64;
    bfree  : int64;
    bavail : int64;
    files  : int64;
    ffree  : int64;
    fsid   : int64;
    owner  : int;
    type_  : int32;
    subtype: int32;
    type_name : string;
    mnt_on : string;
    mnt_from : string;
    flags  : int32;
  }

  let int64_of_fsid fsid =
    let low  = CArray.get (getf fsid Types.Fsid.val_) 0 in
    let high = CArray.get (getf fsid Types.Fsid.val_) 1 in
    Int64.(logor (shift_left (of_int32 high) 32) (of_int32 low))

  let string_of_array a = coerce (ptr char) string (CArray.start a)

  let of_struct s = {
    bsize   = Unsigned.UInt32.to_int (getf s Types.Statfs.bsize);
    iosize  = Int32.to_int (getf s Types.Statfs.iosize);
    blocks  = Unsigned.UInt64.to_int64 (getf s Types.Statfs.blocks);
    bfree   = Unsigned.UInt64.to_int64 (getf s Types.Statfs.bfree);
    bavail  = Unsigned.UInt64.to_int64 (getf s Types.Statfs.bavail);
    files   = Unsigned.UInt64.to_int64 (getf s Types.Statfs.files);
    ffree   = Unsigned.UInt64.to_int64 (getf s Types.Statfs.ffree);
    fsid    = int64_of_fsid (getf s Types.Statfs.fsid);
    owner   = getf s Types.Statfs.owner;
    type_   = Unsigned.UInt32.to_int32 (getf s Types.Statfs.type_);
    subtype = Unsigned.UInt32.to_int32 (getf s Types.Statfs.fssubtype);
    type_name = string_of_array (getf s Types.Statfs.fstypename);
    mnt_on    = string_of_array (getf s Types.Statfs.mntonname);
    mnt_from  = string_of_array (getf s Types.Statfs.mntfromname);
    flags     = Unsigned.UInt32.to_int32 (getf s Types.Statfs.flags);
  }

  let list_of_ptr ptr len =
    let structs = CArray.from_ptr (!@ ptr) len in
    List.map of_struct (CArray.to_list structs)
end

let getmntinfo ?(nowait=false) () =
  let flags = if nowait then C.Fsstat_flags.NOWAIT else C.Fsstat_flags.WAIT in
  Errno_unix.raise_on_errno ~call:"getmntinfo" (fun () ->
    let ptr = allocate (ptr Types.Statfs.t) (from_voidp Types.Statfs.t null) in
    let len = C.getmntinfo ptr flags in
    if len = 0 then None else Some (Statfs.list_of_ptr ptr len)
  )

let statfs path =
  Errno_unix.raise_on_errno ~call:"statfs" (fun () ->
    let statfs_ptr = allocate_n Types.Statfs.t 1 in
    let rc = C.statfs path statfs_ptr in
    if rc <> 0 then None else Some (Statfs.of_struct (!@ statfs_ptr))
  )
