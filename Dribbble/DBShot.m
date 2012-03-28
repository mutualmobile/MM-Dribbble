//
//  DBShot.m
//  Dribbble
//
//  Copyright (c) 2012 Mutual Mobile. All rights reserved.
//

#import "DBShot.h"

#import "DBHTTPClient.h"
#import "DBPlayer.h"
#import "ContainerAdditions.h"

@implementation DBShot

@dynamic player;
@dynamic title;
@dynamic height;
@dynamic width;
@dynamic id;

+ (NSString*)keyPathForResponseObject {
    return @"shots";
}

+ (NSString*)nameForEntityDescription {
    return @"DBShot";
}

+ (void)getShotWithID:(NSString *)shotID context:(NSManagedObjectContext *)context resultBlock:(void (^)(DBShot *))resultBlock failureBlock:(void (^)(NSError *))failureBlock {
    NSString *URN = [NSString stringWithFormat:@"shots/%@", shotID];
    
    [[DBHTTPClient sharedClient] getPath:URN parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dict = responseObject;
        
        DBShot *shot;
        
        NSFetchRequest *shotFetchRequest = [[NSFetchRequest alloc] initWithEntityName:[self nameForEntityDescription]];
        shotFetchRequest.predicate = [NSPredicate predicateWithFormat:@"SELF.id == %@", [dict valueForKey:@"id"]];
        [shotFetchRequest setSortDescriptors:[NSArray array]];
        
        NSError *shotFetchError = nil;
        NSArray *fetchShots = [context executeFetchRequest:shotFetchRequest error:&shotFetchError];
        
        if (shotFetchError == nil && [fetchShots count] > 0) {
            shot = [fetchShots objectAtIndex:0];
        } else {
            shot = [[DBShot alloc] initWithEntity:[NSEntityDescription entityForName:[self nameForEntityDescription] inManagedObjectContext:context] insertIntoManagedObjectContext:context];
        }

        shot.title = [dict valueForKey:@"title"];
        [shot setPrimitiveValue:[dict valueForKey:@"image_url"] forKey:@"image_url"];
        
        NSError *saveError = nil;
        
        [context save:&saveError];
        
        resultBlock(shot);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failureBlock(error);
    }];   
}

+ (void)shotsFromPlayersFollowingUsername:(NSString *)username 
                                     page:(NSInteger)page
                                  context:(NSManagedObjectContext *)context 
                              resultBlock:(void (^)(NSArray *shots, NSInteger pages, NSInteger pageIndex))resultBlock 
                             failureBlock:(void (^)(NSError *))failureBlock {
    NSString *URN = [NSString stringWithFormat:@"players/%@/shots/following?per_page=30&page=%d", username, page];
    
    [[DBHTTPClient sharedClient] getPath:URN parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *parsingError = nil;
        
        NSArray *array = [responseObject valueForKey:[self keyPathForResponseObject]];
        NSMutableArray *shots = [NSMutableArray array];
        
        for (NSDictionary *dict in array) {
            DBShot *shot;
            
            NSFetchRequest *shotFetchRequest = [[NSFetchRequest alloc] initWithEntityName:[self nameForEntityDescription]];
            shotFetchRequest.predicate = [NSPredicate predicateWithFormat:@"SELF.id == %@", [dict valueForKey:@"id"]];
            [shotFetchRequest setSortDescriptors:[NSArray array]];

            NSError *shotFetchError = nil;
            NSArray *fetchShots = [context executeFetchRequest:shotFetchRequest error:&shotFetchError];
            
            if (shotFetchError == nil && [fetchShots count] > 0) {
                shot = [fetchShots objectAtIndex:0];
            } else {
                shot = [[DBShot alloc] initWithEntity:[NSEntityDescription entityForName:[self nameForEntityDescription] inManagedObjectContext:context] insertIntoManagedObjectContext:context];
            }

            shot.title = [dict valueForKey:@"title"];
            [shot setPrimitiveValue:[dict valueForKey:@"image_url"] forKey:@"image_url"];
            
            NSDictionary *playerDict = [dict valueForKey:@"player"];
            
            DBPlayer *player;
            
            NSFetchRequest *playerFetchRequest = [[NSFetchRequest alloc] initWithEntityName:[DBPlayer nameForEntityDescription]];
            playerFetchRequest.predicate = [NSPredicate predicateWithFormat:@"SELF.id == %@", [playerDict valueForKey:@"id"]];
            [playerFetchRequest setSortDescriptors:[NSArray array]];

            NSError *playerFetchError = nil;
            NSArray *players = [context executeFetchRequest:playerFetchRequest error:&playerFetchError];
            
            if (playerFetchError == nil && [players count] > 0) {
                player = [players objectAtIndex:0];
            } else {
                player = [[DBPlayer alloc] initWithEntity:[NSEntityDescription entityForName:[DBPlayer nameForEntityDescription] inManagedObjectContext:context] insertIntoManagedObjectContext:context];
            }

            [player setPrimitiveValue:[playerDict valueForKey:@"avatar_url"] forKey:@"avatar_url"];
            player.name = [playerDict stringForKey:@"name"];
            player.twitterScreenName = [playerDict stringForKey:@"twitter_screen_name"];
            player.location = [playerDict stringForKey:@"location"];
            player.username = [playerDict stringForKey:@"username"];
            
            [shot setValue:player forKey:@"player"];

            [shots addObject:shot];
        }
        
        NSInteger page = [[responseObject valueForKey:@"page"] intValue];
        NSInteger pages = [[responseObject valueForKey:@"pages"] intValue];
        
        if (parsingError == nil) {
            NSError *saveError = nil;
            
            [context save:&saveError];
            
            resultBlock(shots, pages, page);
        } else {
            failureBlock(parsingError);
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failureBlock(error);
    }];
}

+ (void)shotReboundsForShotIdentifier:(NSString *)shotIdentifier 
                              context:(NSManagedObjectContext *)context 
                          resultBlock:(void (^)(NSArray *))resultBlock 
                         failureBlock:(void (^)(NSError *))failureBlock {
    NSString *URN = [NSString stringWithFormat:@"shots/%@/rebounds?per_page=30", shotIdentifier];
    
    [[DBHTTPClient sharedClient] getPath:URN parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *array = [responseObject valueForKey:[self keyPathForResponseObject]];
        NSMutableArray *shots = [NSMutableArray array];
        
        for (NSDictionary *dict in array) {
            DBShot *shot;
            
            NSFetchRequest *shotFetchRequest = [[NSFetchRequest alloc] initWithEntityName:[self nameForEntityDescription]];
            shotFetchRequest.predicate = [NSPredicate predicateWithFormat:@"SELF.id == %@", [dict valueForKey:@"id"]];
            [shotFetchRequest setSortDescriptors:[NSArray array]];
            
            NSError *shotFetchError = nil;
            NSArray *fetchShots = [context executeFetchRequest:shotFetchRequest error:&shotFetchError];
            
            if (shotFetchError == nil && [fetchShots count] > 0) {
                shot = [fetchShots objectAtIndex:0];
            } else {
                shot = [[DBShot alloc] initWithEntity:[NSEntityDescription entityForName:[self nameForEntityDescription] inManagedObjectContext:context] insertIntoManagedObjectContext:context];
            }

            shot.title = [dict valueForKey:@"title"];
            [shot setPrimitiveValue:[dict valueForKey:@"image_url"] forKey:@"image_url"];
            
            [shots addObject:shot];
        }
        
        NSError *saveError = nil;
        
        [context save:&saveError];
        
        resultBlock(shots);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failureBlock(error);
    }];
}

- (NSURL*)imageURL {
    return [NSURL URLWithString:[self primitiveValueForKey:@"image_url"]];
}

- (CGSize)shotSize {
    return CGSizeMake(self.width.floatValue, self.height.floatValue);
}

@end
