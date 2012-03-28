//
//  DBHTTPClient.m
//  Dribbble
//
//  Copyright (c) Mutual Mobile. All rights reserved.
//

#import "DBHTTPClient.h"

#import "AFJSONRequestOperation.h"

@implementation DBHTTPClient

+ (DBHTTPClient *)sharedClient {
    static DBHTTPClient *_sharedClient = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:@"http://api.dribbble.com/"]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
    [self setParameterEncoding:AFFormURLParameterEncoding];
    
    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
	[self setDefaultHeader:@"Accept" value:@"application/json"];
    
    return self;
}

@end
