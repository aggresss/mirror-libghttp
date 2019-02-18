#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>

#include "flag/flag.h"
#include "log/log.h"
#include "ghttp.h"

#define GHTTP_TEST_SUCCESS (0)
#define GHTTP_TEST_FAIL (-1)

int test_http_get(void)

{
    int ret = GHTTP_TEST_FAIL;
    char *uri = "http://cn.bing.com/favicon.ico";
    ghttp_request *request = NULL;
    ghttp_status status;
    int http_code;
    char *buf;
    int nBodyLen;

    request = ghttp_request_new();
    if(ghttp_set_uri(request, uri) == -1)
        goto ec;
    if(ghttp_set_type(request, ghttp_type_get) == -1)
        goto ec;
    ghttp_prepare(request);
    status = ghttp_process(request);
    if(status == ghttp_error)
        goto ec;
    http_code = ghttp_status_code(request);
    LogDebug("http code: %d", http_code);
    if (http_code <= 0)
        goto ec;
    buf = ghttp_get_body(request);
    if (!buf)
        goto ec;
    nBodyLen = ghttp_get_body_len(request);
    LogDebug("http body length: %d", nBodyLen);
    if (nBodyLen <= 0)
        goto ec;
    ret = GHTTP_TEST_SUCCESS;
ec:
    ghttp_request_destroy(request);
    return ret;
}


typedef struct _CmdArg {
        bool bTestHttpGet;
}CmdArg;

int main(int argc, const char * argv[])
{
    int ret = GHTTP_TEST_FAIL;
    CmdArg cmdArg;
    memset(&cmdArg, 0, sizeof(cmdArg));
    cmdArg.bTestHttpGet = false;

    SetLogLevel(LOG_LEVEL_TRACE);

    flag_bool(&cmdArg.bTestHttpGet, "http_get", "test http get");

    flag_parse(argc, argv, "test libghttp");
    if (cmdArg.bTestHttpGet) {
        ret = test_http_get();
    }
ec:
    return ret;
}
