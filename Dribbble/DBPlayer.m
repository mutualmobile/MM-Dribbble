//
//  DBPlayer.m
//  Dribbble
//
//  Copyright (c) 2012 Mutual Mobile. All rights reserved.
//

#import "DBPlayer.h"

@implementation DBPlayer

@dynamic username;
@dynamic name;
@dynamic location;
@dynamic twitterScreenName;
@dynamic shots;
@dynamic avatarURL;
@dynamic id;

- (NSURL*)avatarURL {
    return [NSURL URLWithString:[self primitiveValueForKey:@"avatar_url"]];
}

+ (NSString*)keyPathForResponseObject {
    return @"player";
}

+ (NSString*)nameForEntityDescription {
    return @"DBPlayer";
}

@end
