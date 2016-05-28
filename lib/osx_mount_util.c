#include <caml/mlvalues.h>
#include <caml/threads.h>
#include <sys/param.h>
#include <sys/ucred.h>
#include <sys/mount.h>

int osx_mount_getmntinfo(struct statfs **mntbufp, int flags)
{
  int r;
  caml_release_runtime_system();
  r = getmntinfo(mntbufp, flags);
  caml_acquire_runtime_system();
  return r;
}

int osx_mount_statfs(const char *path, struct statfs *buf)
{
  int r;
  caml_release_runtime_system();
  r = statfs(path, buf);
  caml_acquire_runtime_system();
  return r;
}
