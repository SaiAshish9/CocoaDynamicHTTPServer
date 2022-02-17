#import "MyHTTPConnection.h"
#import "HTTPMessage.h"
#import "HTTPDataResponse.h"
#import "DDNumber.h"
#import "HTTPLogging.h"

static const int httpLogLevel = HTTP_LOG_LEVEL_WARN;

@implementation MyHTTPConnection

- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path
{
    HTTPLogTrace();
    if ([method isEqualToString:@"GET"])
    {
        if ([path isEqualToString:@"/"])
        {
            return requestContentLength < 50;
        }
    }
    return [super supportsMethod:method atPath:path];
}

- (BOOL)expectsRequestBodyFromMethod:(NSString *)method atPath:(NSString *)path
{
    HTTPLogTrace();
    if([method isEqualToString:@"GET"])
        return YES;
    return [super expectsRequestBodyFromMethod:method atPath:path];
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
{
    HTTPLogTrace();
    if ([method isEqualToString:@"GET"] && [path isEqualToString:@"/"])
    {
        HTTPLogVerbose(@"%@[%p]: postContentLength: %qu", THIS_FILE, self, requestContentLength);
        NSString *postStr = nil;
        NSData *postData = [request body];
        if (postData)
        {
            postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
        }
        HTTPLogVerbose(@"%@[%p]: postStr: %@", THIS_FILE, self, postStr);
        NSLog(@"%@",postStr);
        NSData *response = postData;
        return [[HTTPDataResponse alloc] initWithData:response];
    }
    return [super httpResponseForMethod:method URI:path];
}

- (void)prepareForBodyWithSize:(UInt64)contentLength
{
    HTTPLogTrace();
}

- (void)processBodyData:(NSData *)postDataChunk
{
    HTTPLogTrace();
    BOOL result = [request appendData:postDataChunk];
    if (!result)
    {
        HTTPLogError(@"%@[%p]: %@ - Couldn't append bytes!", THIS_FILE, self, THIS_METHOD);
    }
}

@end
