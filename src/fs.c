#include <stdio.h>

#define COPY_BLOCK 4096

/* Returns 0 on success, nonzero on error. */
int Neo_FS_CopyFile(const char *srcPath, const char *dstPath)
{
    FILE *src;
    FILE *dst;
    char buf[COPY_BLOCK];
    size_t nread;

    src = fopen(srcPath, "rb");
    if (src == NULL)
        return -1;

    dst = fopen(dstPath, "wb");
    if (dst == NULL) {
        fclose(src);
        return -1;
    }

    while ((nread = fread(buf, 1, COPY_BLOCK, src)) > 0) {
        if (fwrite(buf, 1, nread, dst) != nread) {
            fclose(src);
            fclose(dst);
            return -1;
        }
    }

    if (ferror(src)) {
        fclose(src);
        fclose(dst);
        return -1;
    }

    fclose(src);
    if (fclose(dst) != 0)
        return -1;

    return 0;
}