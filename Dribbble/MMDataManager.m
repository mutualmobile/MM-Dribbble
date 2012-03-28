//
//  MMDataManager.m
//  Dribbble
//
//  Copyright (c) 2012 Mutual Mobile. All rights reserved.
//

#import "MMDataManager.h"
#import "AFHTTPRequestOperationLogger.h"
#import <CoreData/CoreData.h>

static MMDataManager* MM_sharedDataManager;

@implementation MMDataManager

- (id)init {
	assert(MM_sharedDataManager == nil);
	
	if ((self = [super init])) {
		
	}
	
	return self;
}

- (BOOL)save {
	NSError* error = nil;
	if (![self.managedObjectContext save:&error]) {
		[self handleFatalCoreDataError:error];
		return NO;
	}
	
	return YES;
}

- (NSURL*)databaseURL {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
	NSString *homeDirectory = [paths objectAtIndex:0];
	
	NSString* databaseFilename = [homeDirectory stringByAppendingPathComponent:@"Dribbble.sqlite"];	
	return [NSURL fileURLWithPath:databaseFilename];
}

- (NSManagedObjectContext*)managedObjectContext {
	if (MM_managedObjectContext != nil) {
		return MM_managedObjectContext;
	}
	
	MM_managedObjectContext = [[NSManagedObjectContext alloc] init];
	MM_managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
	
	return MM_managedObjectContext;
}
- (NSPersistentStoreCoordinator*)persistentStoreCoordinator {
	if (MM_persistentStoreCoordinator != nil) {
		return MM_persistentStoreCoordinator;
	}
	
	MM_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    
	NSError* error = nil;
	if (![MM_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType 
                                                     configuration:nil 
                                                               URL:[self databaseURL] 
                                                           options:nil error:&error]) 
    {
		[self handleFatalCoreDataError:error];
		return nil;
	}
    
	return MM_persistentStoreCoordinator;
}
- (NSManagedObjectModel*)managedObjectModel {
	if (MM_managedObjectModel != nil) {
		return MM_managedObjectModel;
	}
	
	MM_managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
	
	return MM_managedObjectModel;
}

- (void)handleFatalCoreDataError:(NSError*)error {
	// TODO: Much more graceful error handling.
	
	NSLog(@"Core data error:");
	NSLog(@"%@", error);
	NSLog(@"%@", [error userInfo]);
	
    [[NSFileManager defaultManager] removeItemAtPath:self.databaseURL.path error:NULL];

	abort();
}

#pragma mark static
+ (MMDataManager*)sharedDataManager {
	if (MM_sharedDataManager == nil) {
		MM_sharedDataManager = [[MMDataManager alloc] init];
#ifdef DEBUG
        [[AFHTTPRequestOperationLogger sharedLogger] startLogging];
        [[AFHTTPRequestOperationLogger sharedLogger] setLevel:AFLoggerLevelInfo];
#endif
	}
	
	return MM_sharedDataManager;
}

@end
