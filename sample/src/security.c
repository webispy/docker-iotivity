#include <stdio.h>
#include <unistd.h>
#include <iotivity_config.h>
#include <platform_features.h>
#include <ocstack.h>

#include "security.h"

static FILE *on_open(const char *path, const char *mode)
{
	return fopen(path, mode);
}

static size_t on_read(void *ptr, size_t size, size_t nmemb, FILE *fp)
{
	return fread(ptr, size, nmemb, fp);
}

static size_t on_write(const void *ptr, size_t size, size_t nmemb, FILE *fp)
{
	return fwrite(ptr, size, nmemb, fp);
}

static int on_close(FILE *fp)
{
	return fclose(fp);
}

static int on_unlink(const char *path)
{
	return unlink(path);
}

OCPersistentStorage ps = {
	.open = on_open,
	.read = on_read,
	.write = on_write,
	.close = on_close,
	.unlink = on_unlink
};

int my_client_security_init(void)
{
	OCRegisterPersistentStorageHandler(&ps);

	return 0;
}
