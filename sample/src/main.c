#include <stdio.h>
#include <time.h>
#include <iotivity_config.h>
#include <platform_features.h>
#include <ocstack.h>
#include <ocpayload.h>

#include "security.h"

static OCStackApplicationResult on_discovery(void *ctx, OCDoHandle handle,
		OCClientResponse *resp)
{
	if (!resp)
		return OC_STACK_KEEP_TRANSACTION;

	printf("Discovered %s:%d\n", resp->devAddr.addr, resp->devAddr.port);

	return OC_STACK_KEEP_TRANSACTION;
}

static int do_discovery(void)
{
	OCCallbackData *cb;

	cb = malloc(sizeof(OCCallbackData));
	cb->cb = on_discovery;
	cb->context = NULL;
	cb->cd = NULL;

	return OCDoRequest(NULL, OC_REST_DISCOVER, "/oic/res",
			NULL, NULL, CT_DEFAULT,
			OC_LOW_QOS, cb, NULL, 0);
}

int main(int argc, char *argv[])
{
	struct timespec timeout;

	printf("\nIoTivity(%s) client\n", IOTIVITY_VERSION);

	if (my_client_security_init() < 0)
		return -1;

	printf("Start IoTivity stack...\n");

	if (OCInit(NULL, 0, OC_CLIENT) != OC_STACK_OK) {
		printf("OCStack init error\n");
		return -1;
	}

	do_discovery();

	timeout.tv_sec = 0;
	timeout.tv_nsec = 10000000L; /* 0.01 sec */

	while (1) {
		if (OCProcess() != OC_STACK_OK) {
			printf("OCStack process error\n");
			return -1;
		}

		nanosleep(&timeout, NULL);
	}

	if (OCStop() != OC_STACK_OK)
		printf("OCStack process error\n");

	return 0;
}
