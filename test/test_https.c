#include <stdio.h>
#include <string.h>
#include "libghttp/ghttp.h"
#include "CuTest/CuTest.h"

void test_https_setup(CuTest *tc)
{

}


void test_https_get(CuTest *tc)
{
    char *uri = "http://kodo.router7.com/index.html";
    ghttp_request *request = NULL;
    ghttp_status status;
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
    /* OK, done */
    CuAssertIntEquals(tc, 200, ghttp_status_code(request));
    buf = ghttp_get_body(request);
    bytes_read = ghttp_get_body_len(request);
    return ;
}


void test_https_cleanup(CuTest *tc)
{

}



CuSuite *test_http(CuTest *tc)
{
        CuSuite* suite = CuSuiteNew();

        SUITE_ADD_TEST(suite, (void*)test_https_setup);
        SUITE_ADD_TEST(suite, (void*)test_https_get);
        SUITE_ADD_TEST(suite, (void*)test_https_cleanup);

        return suite;
}
