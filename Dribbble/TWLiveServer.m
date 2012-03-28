//
//  TWLiveServer.m
//  Dribbble
//
//  Created by Conrad Stoll on 3/6/12.
//  Copyright (c) 2012 University of Texas. All rights reserved.
//

#import "TWLiveServer.h"

#import "TWHTTPClient.h"

#import "AFJSONRequestOperation.h"

@implementation TWLiveServer

+ (void)cancelRequests {
    [[TWHTTPClient sharedClient] cancelAllHTTPOperationsWithMethod:nil path:nil];
}

+ (void)startRequestWithURN:(NSString *)URN 
                       data:(NSDictionary *)data
              responseBlock:(void (^)(id responseObject))responseBlock 
               failureBlock:(void (^)(NSError *error))failureBlock { 
    [[TWHTTPClient sharedClient] getPath:URN parameters:data success:^(AFHTTPRequestOperation *operation, id responseObject) {
        responseBlock(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        AFJSONRequestOperation *jsonOperation = (AFJSONRequestOperation*)operation;
        NSLog(@"error url: %@", jsonOperation.request.URL);
        
        if ([jsonOperation isKindOfClass:[AFJSONRequestOperation class]]) {
            NSLog(@"error response:%@", jsonOperation.responseJSON);
        }
        
        failureBlock(error);
    }];
}

+ (timeoutBlock)timeoutBlock {
    return ^(){
        // Do Stuff...
    };
}

@end
