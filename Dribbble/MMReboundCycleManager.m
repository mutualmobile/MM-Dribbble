//
//  MMReboundCycleManager.m
//  Dribbble
//
//  Copyright (c) 2012 Mutual Mobile. All rights reserved.
//

#import "MMReboundCycleManager.h"

#import "DBShot.h"
#import "DBPlayer.h"
#import "MMDataManager.h"

@interface MMReboundCycleManager ()

@property (nonatomic, strong)   NSMutableOrderedSet *shotObjectIDs;
@property (nonatomic, strong)   NSString *shotIdentifier;
@property (nonatomic)           NSInteger currentShotIndex;

@property (nonatomic)           NSTimeInterval cycleInterval;
@property (nonatomic)           NSTimeInterval refreshInterval;

@property (nonatomic, strong)   NSTimer *cycleTimer;
@property (nonatomic, strong)   NSTimer *refreshTimer;

@end

@implementation MMReboundCycleManager

@synthesize delegate = delegate_;
@synthesize shotObjectIDs = shotObjectIDs_;
@synthesize shotIdentifier = shotIdentifier_;
@synthesize currentShotIndex = currentShotIndex_;
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

- (void)updateCycleShot {
    if ([self.shotObjectIDs count] == 0)
        return;
    
    if (self.currentShotIndex >= [self.shotObjectIDs count]) {
        self.currentShotIndex = 0;
    }
    
    NSManagedObjectID *objectID = [self.shotObjectIDs objectAtIndex:self.currentShotIndex];
    
    DBShot *shot = (DBShot*)[[[MMDataManager sharedDataManager] managedObjectContext] objectWithID:objectID];
    
    if (self.currentShotIndex == [self.shotObjectIDs count] - 1) {
        [self.delegate reboundCycleManager:self didUpdateToCurrentShot:shot];
    } else {
        [self.delegate reboundCycleManager:self didUpdateToNextShot:shot];
    }
    
    self.currentShotIndex++;
}

- (void)refreshShots {
    NSManagedObjectContext *context = [[MMDataManager sharedDataManager] managedObjectContext];

    [DBShot 
     shotReboundsForShotIdentifier:self.shotIdentifier 
     context:context
     resultBlock:^(NSArray *shots) {
         for (int i = [shots count] - 1; i >= 0; i--) {
             DBShot *shot = [shots objectAtIndex:i];
             
             [self.shotObjectIDs addObject:shot.objectID];
         }
     } failureBlock:^(NSError *error) {
         
     }];
}

- (void)beginReboundCycleWithCycleInterval:(NSTimeInterval)cycleInterval 
                           refreshInterval:(NSTimeInterval)refreshInterval
                            shotIdentifier:(NSString *)shotIdentifier {
    [self.cycleTimer invalidate];
    [self.refreshTimer invalidate];
    
    self.shotObjectIDs = nil;
    self.cycleTimer = nil;
    self.refreshTimer = nil;
    
    self.cycleInterval = cycleInterval;
    self.refreshInterval = refreshInterval;
    self.shotIdentifier = shotIdentifier;
    
    NSManagedObjectContext *context = [[MMDataManager sharedDataManager] managedObjectContext];
    
    [DBShot getShotWithID:shotIdentifier context:context resultBlock:^(DBShot *object) {
        self.shotObjectIDs = [NSMutableOrderedSet orderedSet];

        [self.shotObjectIDs addObject:object.objectID];
        
        [DBShot 
         shotReboundsForShotIdentifier:shotIdentifier 
         context:context
         resultBlock:^(NSArray *shots) {
             for (int i = [shots count] - 1; i >= 0; i--) {
                 DBShot *shot = [shots objectAtIndex:i];
                 
                 [self.shotObjectIDs addObject:shot.objectID];
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
             
             self.currentShotIndex = 0;
             
             [self updateCycleShot];
         } failureBlock:^(NSError *error) {
             
         }];
    } failureBlock:^(NSError *error) {
        
    }];
}

@end
