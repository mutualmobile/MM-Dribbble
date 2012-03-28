//
//  TWTweet.m
//  Dribbble
//
//  Copyright (c) 2012 Mutual Mobile. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "TWTweet.h"
#import "TWHTTPClient.h"

@implementation TWTweet

+ (NSString*)keyPathForResponseObject {
    return @"results";
}

+ (NSString*)nameForEntityDescription {
    return @"TWTweet";
}

+ (void)tweetsForSearchString:(NSString*)text 
                  maxIdString:(NSString*)maxIdString
                      context:(NSManagedObjectContext*)context
                  resultBlock:(void(^)(NSArray *tweetss))resultBlock
                 failureBlock:(void(^)(NSError* error))failureBlock;  {
    NSMutableString * parameterString = [NSMutableString stringWithFormat:@"search.json?q=%@&rpp=100", text];
    if(maxIdString!=nil){
        [parameterString appendFormat:@"&since_id=%@",maxIdString];
    }
    
    NSString *URN = parameterString;
    
    [[TWHTTPClient sharedClient] getPath:URN parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *array = [responseObject valueForKey:[self keyPathForResponseObject]];
        NSMutableArray *tweets = [NSMutableArray array];
        
        for (NSDictionary *dict in array) {
            TWTweet *tweet;
            
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:[self nameForEntityDescription]];
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"SELF.id == %@", [dict valueForKey:@"id"]];
            [fetchRequest setSortDescriptors:[NSArray array]];
            
            NSError *fetchError = nil;
            NSArray *fetchTweets = [context executeFetchRequest:fetchRequest error:&fetchError];
            
            if (fetchError == nil && [fetchTweets count] > 0) {
                tweet = [fetchTweets objectAtIndex:0];
            } else {
                tweet = [[TWTweet alloc] initWithEntity:[NSEntityDescription entityForName:[self nameForEntityDescription] inManagedObjectContext:context] insertIntoManagedObjectContext:context];
            }

            [tweet setPrimitiveValue:[dict valueForKey:@"text"] forKey:@"text"];
            
            [tweets addObject:tweet];
        }
        
        NSError *saveError = nil;
        
        [context save:&saveError];
        
        resultBlock(tweets);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failureBlock(error);
    }];
}

#pragma mark - custom properties
- (NSString*)tweet{
    return [self primitiveValueForKey:@"text"];
}

- (NSString*)username{
    return [self primitiveValueForKey:@"from_user"];
}

- (NSString*)userFullName{
    return [self primitiveValueForKey:@"from_user_name"];
}

- (NSURL*)userPhotoURL{
    return [NSURL URLWithString:[self primitiveValueForKey:@"profile_image_url"]];
}

- (NSInteger)tweetId{
    return [[self primitiveValueForKey:@"id"] intValue];
}

- (NSString *)tweetIdString{
    return [self primitiveValueForKey:@"id_str"];
}


@end
