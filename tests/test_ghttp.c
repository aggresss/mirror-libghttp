#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>
#include <unistd.h>

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


int test_http_download()
{
    int ret = GHTTP_TEST_FAIL;
    char *uri = "http://link.router7.com:8091/Cp8ugVw-i8WAJU9EAEnLHjlJfMc620.zip";
    ghttp_request *request = NULL;
    ghttp_status status;
    ghttp_current_status current_status;
    int http_code;
    char *buf;
    int nBodyLen = 0;
    int nTotalLen = 0;
    FILE* fptr;
    fptr = fopen("/tmp/http_down.test", "wb");
    if (fptr == NULL) {
        LogError("Error to open file!");
        goto ec;
    }

    /* create new request */
    request = ghttp_request_new();

    /* set request*/
    if(ghttp_set_uri(request, uri) == -1)
        goto ec;
    if(ghttp_set_type(request, ghttp_type_get) == -1)
        goto ec;
    if(ghttp_set_sync(request, ghttp_async) == -1)
        goto ec;
    ghttp_set_timeout(request, 5);
    ghttp_set_chunksize(request, 256*1024);

    /* connect */
    ghttp_prepare(request);

    /* receive */
    do {
        status = ghttp_process(request);
        current_status = ghttp_get_status(request);
        LogDebug("ghttp current status: %d, read: %d, total:%d",
                current_status.proc, current_status.bytes_read, current_status.bytes_total);
        switch (current_status.proc) {
        case ghttp_proc_request:
            LogDebug("Send http request.");
            break;
        case ghttp_proc_response_hdrs:
            LogDebug("Process header.");
            break;
        case ghttp_proc_response:
            LogDebug("Downloads.");
            break;
        default:
            break;
        }

    } while (status != ghttp_done);

    buf = ghttp_get_body(request);
     if (buf) {
         nBodyLen = ghttp_get_body_len(request);
         ret = fwrite(buf, 1, nBodyLen, fptr);
         if (ret != nBodyLen)
             goto ec;
     }


    ret = GHTTP_TEST_SUCCESS;
ec:
    ghttp_request_destroy(request);
    fclose(fptr);
    return ret;
}


typedef struct _CmdArg {
        bool bTestHttpGet;
        bool bTestHttpDown;
}CmdArg;

int main(int argc, const char * argv[])
{
    int ret = GHTTP_TEST_FAIL;
    CmdArg cmdArg;
    memset(&cmdArg, 0, sizeof(cmdArg));
    cmdArg.bTestHttpGet = false;
    cmdArg.bTestHttpDown = false;

    SetLogLevel(LOG_LEVEL_TRACE);

    flag_bool(&cmdArg.bTestHttpGet, "http_get", "test http get");
    flag_bool(&cmdArg.bTestHttpDown, "http_download", "test http download");

    flag_parse(argc, argv, "test libghttp");

    if (cmdArg.bTestHttpGet) {
        ret = test_http_get();
        if (ret != 0) {
            goto ec;
        }
    }

    if (cmdArg.bTestHttpDown) {
        ret = test_http_download();
        if (ret != 0) {
            goto ec;
        }
    }
ec:
    return ret;
}
