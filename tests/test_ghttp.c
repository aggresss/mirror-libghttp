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


static int test_http_download(char *_pPath, char *_pUrl)
{
    const int l_chunk_size = 128 * 1024;
    int n = 0;
    int ret = -1;
    ghttp_request *request = NULL;
    ghttp_status status;
    ghttp_current_status current_status;
    int ReturnCode = 0;
    int current_body_len = 0;
    int current_file_wirte = 0;
    int bytes_save = 0;
    int FileSize;
    char *RespBody = NULL;
    FILE* fptr;
    int report_percent = 0;

    if (!_pPath || !_pUrl || strlen(_pUrl) == 0) {
        printf("Download args error.\n");
        return ret;
    }

    request = ghttp_request_new();
    if (ghttp_set_uri(request, _pUrl) == ghttp_error)
        goto ec;
    printf("Download Url: %s\n", _pUrl);
    if (ghttp_set_type(request, ghttp_type_get) == ghttp_error)
        goto ec;
    if (ghttp_set_sync(request, ghttp_async) == ghttp_error)
        goto ec;
    ghttp_set_timeout(request, 3);
    ghttp_set_chunksize(request, l_chunk_size);

    /* connect */
    ghttp_prepare(request);
    printf("Download start.\n");
    /* receive */
    do {
        status = ghttp_process(request);
        if (status == ghttp_error) {
            goto ec;
        }
        current_status = ghttp_get_status(request);

        switch (current_status.proc) {
        case ghttp_proc_request:
            printf("Download request send.\n");
            break;
        case ghttp_proc_response_hdrs:
            printf("Download request responsed.\n");
            break;
        case ghttp_proc_response:
            /* check if return code error */
            if(!ReturnCode) {
                ReturnCode = ghttp_status_code(request);
                printf("Download return code: %d\n", ReturnCode);
                if (ReturnCode >= 400 || ReturnCode < 200) {
                    goto ec;
                }
                fptr = fopen(_pPath, "wb");
                if (fptr == NULL) {
                    printf("Error to open file!\n");
                    goto ec;
                }
            }
            if ((current_status.bytes_read - bytes_save) >= l_chunk_size) {
                /* flush buf to resp body and save resp body to file */
                ghttp_flush_response_buffer(request);
                current_body_len = ghttp_get_body_len(request);
                if (current_body_len) {
                    RespBody = ghttp_get_body(request);
                    if (!RespBody) {
                        printf("Get resp body error!\n");
                        goto fc;
                    }
                    current_file_wirte = fwrite(RespBody, 1, current_body_len, fptr);
                    if (current_file_wirte != current_body_len) {
                        printf("File write error!\n");
                        goto fc;
                    }
                    bytes_save += current_body_len;
                }
            }

            /* print progress */
            if (current_status.bytes_total > 0) {
                if (current_status.bytes_read * 100 / current_status.bytes_total >= report_percent + 2) {
                    report_percent = current_status.bytes_read * 100 / current_status.bytes_total;
                    printf("Download %02d%% completed.\n", report_percent);
                }
            }
            //usleep(100*1000);
            break;
        case ghttp_proc_none:
            break;
        default:
            goto ec;
        }
    } while (status != ghttp_done);

    /* get buffer remain */
    current_body_len = ghttp_get_body_len(request);
    RespBody = ghttp_get_body(request);
    if (current_body_len && RespBody) {
        current_file_wirte = fwrite(RespBody, 1, current_body_len, fptr);
        if (current_file_wirte != current_body_len) {
            printf("File write error!\n");
            goto fc;
        }
        bytes_save += current_body_len;
    }
    printf("Download 100%% completed.\n");
    printf("File write %d bytes.\n", bytes_save);
    ret = 0;
fc:
    fclose(fptr);
ec:
    ghttp_request_destroy(request);
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
        char *path = "/tmp/test.zip";
        char *uri = "http://kodo.router7.com/test.zip";
        ret = test_http_download(path, uri);
        if (ret != 0) {
            goto ec;
        }
    }
ec:
    return ret;
}
