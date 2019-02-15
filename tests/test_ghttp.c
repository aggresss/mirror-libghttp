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
    char *uri = "http://cn.bing.com/favicon.ico";
    ghttp_request *request = NULL;
    ghttp_status status;
    int http_code;
    char *buf;
    int bytes_read;

    request = ghttp_request_new();
    if(ghttp_set_uri(request, uri) == -1)
        exit(-1);
    if(ghttp_set_type(request, ghttp_type_get) == -1)
        exit(-1);
    ghttp_prepare(request);
    status = ghttp_process(request);
    if(status == ghttp_error)
        exit(-1);
    http_code = ghttp_status_code(request);
    LogDebug("http_code: %d", http_code);
    if (200 != http_code) {
        return GHTTP_TEST_FAIL;
    }
    buf = ghttp_get_body(request);
    bytes_read = ghttp_get_body_len(request);
    ghttp_request_destroy(request);
    return GHTTP_TEST_SUCCESS;
}



typedef struct _CmdArg {
        bool bTestHttpGet;
}CmdArg;


int main(int argc, const char * argv[])
{
    int ret;
    CmdArg cmdArg;
    memset(&cmdArg, 0, sizeof(cmdArg));
    cmdArg.bTestHttpGet = false;

    SetLogLevel(LOG_LEVEL_TRACE);

    flag_bool(&cmdArg.bTestHttpGet, "http_get", "test http get");

    flag_parse(argc, argv, "test libghttp");
    if (cmdArg.bTestHttpGet) {
        test_http_get();
    }

    return GHTTP_TEST_SUCCESS;
}
