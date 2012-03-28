//
//  MMShotCycleManager.m
//  Dribbble
//
//  Copyright (c) 2012 Mutual Mobile. All rights reserved.
//

#import "MMShotCycleManager.h"

#import "DBShot.h"
#import "DBPlayer.h"
#import "MMDataManager.h"

@interface MMShotCycleManager ()

@property (nonatomic, strong)   NSMutableOrderedSet *shotObjectIDs;
@property (nonatomic)           NSInteger numOnDeckPlayers;
@property (nonatomic, strong)   NSString *username;
@property (nonatomic)           NSTimeInterval cycleInterval;
@property (nonatomic)           NSTimeInterval refreshInterval;

@property (nonatomic, strong)   NSTimer *cycleTimer;
@property (nonatomic, strong)   NSTimer *refreshTimer;

@end

@implementation MMShotCycleManager

@synthesize delegate = delegate_;
@synthesize shotObjectIDs = shotObjectIDs_;
@synthesize username = username_;
@synthesize numOnDeckPlayers = numOnDeckPlayers_;
@synthesize refreshInterval = refreshInterval_;
@synthesize cycleInterval = cycleInterval_;

@synthesize cycleTimer = cycleTimer_;
@synthesize refreshTimer = refreshTimer_;

- (void)stopUpdating {
    [self.cycleTimer invalidate];
    [self.refreshTimer invalidate];
    
    self.shotObjectIDs = nil;
    self.cycleTimer = nil;
    self.refreshTimer = nil;
}

- (NSMutableArray*)onDeckPlayers {  // Next x Players including Current Player
    NSMutableArray *players = [NSMutableArray array];
    
    for (int i = 0; i < self.numOnDeckPlayers; i++) {
        if ([self.shotObjectIDs count] > i) {
            NSManagedObjectID *objectID = [self.shotObjectIDs objectAtIndex:i];

            DBShot *shot = (DBShot*)[[[MMDataManager sharedDataManager] managedObjectContext] objectWithID:objectID];
            DBPlayer *player = shot.player;
            
            if (player != nil)
                [players addObject:player];
        } else {
            break;
        }
    }
    
    return players;
}

- (void)updateCycleShot {
    if ([self.shotObjectIDs count] == 0)
            return;
    
    NSManagedObjectID *objectID = [self.shotObjectIDs objectAtIndex:0];
    
    DBShot *shot = (DBShot*)[[[MMDataManager sharedDataManager] managedObjectContext] objectWithID:objectID];
    
    NSMutableArray *players = [self onDeckPlayers];
    
    [self.shotObjectIDs removeObject:objectID];
    [self.shotObjectIDs addObject:objectID];
        
    [self.delegate shotCycleManager:self didUpdateToShot:shot onDeckPlayers:players];
}

- (void)refreshShots {
    [DBShot
     shotsFromPlayersFollowingUsername:self.username
     page:1
     context:[[MMDataManager sharedDataManager] managedObjectContext]
     resultBlock:^(NSArray *shots, NSInteger pages, NSInteger pageIndex) {         
         for (DBShot *shot in shots) {
             [self.shotObjectIDs addObject:[shot objectID]];
         }
         
         for (int i = 2; i < pages; ++i) {
             [DBShot
              shotsFromPlayersFollowingUsername:self.username
              page:i
              context:[[MMDataManager sharedDataManager] managedObjectContext]
              resultBlock:^(NSArray *shots, NSInteger pages, NSInteger pageIndex) {
                  for (DBShot *shot in shots) {
                      [self.shotObjectIDs addObject:[shot objectID]];
                  }
              } failureBlock:^(NSError *error) {
                  
              }];
         }
     } failureBlock:^(NSError *error) {
         
     }];
}

- (void)beginShotCycleWithCycleInterval:(NSTimeInterval)cycleInterval 
                        refreshInterval:(NSTimeInterval)refreshInterval 
                      followingUsername:(NSString *)username 
                  numberOfOnDeckPlayers:(NSInteger)numPlayers {
    [self.cycleTimer invalidate];
    [self.refreshTimer invalidate];
    
    self.shotObjectIDs = nil;
    self.cycleTimer = nil;
    self.refreshTimer = nil;
                          
    self.cycleInterval = cycleInterval;
    self.refreshInterval = refreshInterval;
    self.username = username;
    self.numOnDeckPlayers = numPlayers;
        
    [DBShot
     shotsFromPlayersFollowingUsername:username
     page:1
     context:[[MMDataManager sharedDataManager] managedObjectContext]
     resultBlock:^(NSArray *shots, NSInteger pages, NSInteger pageIndex) {
         self.shotObjectIDs = [NSMutableOrderedSet orderedSet];
         
         for (DBShot *shot in shots) {
             [self.shotObjectIDs addObject:[shot objectID]];
         }
         
         self.cycleTimer = [NSTimer timerWithTimeInterval:self.cycleInterval
                                                   target:self 
                                                 selector:@selector(updateCycleShot)
                                                 userInfo:nil
                                                  repeats:YES];
         
         self.refreshTimer = [NSTimer timerWithTimeInterval:self.refreshInterval
                                                   target:self 
                                                 selector:@selector(refreshShots)
                                                 userInfo:nil
                                                  repeats:YES];
         
         [[NSRunLoop mainRunLoop] addTimer:self.cycleTimer forMode:NSDefaultRunLoopMode];
         [[NSRunLoop mainRunLoop] addTimer:self.refreshTimer forMode:NSDefaultRunLoopMode];
         
         [self updateCycleShot];
         
         for (int i = 2; i < pages; ++i) {
             [DBShot
              shotsFromPlayersFollowingUsername:username
              page:i
              context:[[MMDataManager sharedDataManager] managedObjectContext]
              resultBlock:^(NSArray *shots, NSInteger pages, NSInteger pageIndex) {
                  for (DBShot *shot in shots) {
                      [self.shotObjectIDs addObject:[shot objectID]];
                  }
             } failureBlock:^(NSError *error) {
                 
             }];
         }
     } failureBlock:^(NSError *error) {
         
     }];
}


@end
