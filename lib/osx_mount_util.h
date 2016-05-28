#include <sys/mount.h>

int osx_mount_getmntinfo(struct statfs **mntbufp, int flags);
int osx_mount_statfs(const char *path, struct statfs *buf);
