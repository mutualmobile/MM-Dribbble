//
//  ContainerAdditions.m
//
//  Copyright 2011 Mutual Mobile. All rights reserved.
//

#import "ContainerAdditions.h"


@implementation NSArray (ContainerAdditions)

+ (id)arrayWithContentsOfPropertyListNamed:(NSString*)propertyListName
{
    return [self arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:propertyListName ofType:@"plist"]];
}


- (NSUInteger)lastIndex
{
	NSUInteger count = [self count];
	return (count > 0) ? (count - 1) : NSNotFound;
}

@end


@implementation NSDictionary (ContainerAdditions)

+ (id)dictionaryWithContentsOfPropertyListNamed:(NSString*)propertyListName
{
	return [self dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:propertyListName ofType:@"plist"]];
}

// if the dictionary contains NSNull for the key, return nil
- (id)nonNullObjectForKey:(id)key
{
	id object = [self objectForKey:key];
	
	if (object == [NSNull null])
	{
		object = nil;
	}
	
	return object;
}


- (BOOL)containsKey:(id)key
{
	id object = [self nonNullObjectForKey:key];
	
	return (object != nil);
}

- (BOOL)containsKeys:(id)keys, ...
{
    BOOL containsKey = [self containsKey:keys];
    
    if (!containsKey)
        return NO;
    
    va_list argumentList;
    if (keys != nil)                     
    {                               
        id eachItem;
        va_start(argumentList, keys);       
        while((eachItem = va_arg(argumentList, id))) 
        {
            containsKey = [self containsKey:eachItem];
            if (!containsKey)
                return NO;
        }
        va_end(argumentList);
    } 
    
    return YES;
}

- (BOOL)containsKeysInArray:(NSArray *)keys 
{
    for (id key in keys) 
    {
        BOOL containsKey = [self containsKey:key];
        
        if (!containsKey)
            return NO;
    }
    
    return YES;
}

- (BOOL)boolForKey:(id)key
{
	BOOL result = NO;
	
	id object = [self nonNullObjectForKey:key];
	if ((object != nil) && ([object respondsToSelector:@selector(boolValue)]))
	{
		result = [object boolValue];
	}
	
	return result;
}


- (NSDictionary*)dictionaryForKey:(id)key
{
	return [self nonNullObjectForKey:key];
}


- (double)doubleForKey:(id)key
{
	double result = 0.0;
	
	id object = [self nonNullObjectForKey:key];
	if ((object != nil) && ([object respondsToSelector:@selector(doubleValue)]))
	{
		result = [object doubleValue];
	}
	
	return result;
}


- (NSInteger)integerForKey:(id)key
{
	NSUInteger result = 0;
	
	id object = [self nonNullObjectForKey:key];
	if ((object != nil) && ([object respondsToSelector:@selector(integerValue)]))
	{
		result = [object integerValue];
	}
	
	return result;
}


- (NSUInteger)unsignedIntegerForKey:(id)key
{
	NSUInteger result = 0;
	
	id object = [self nonNullObjectForKey:key];
	if ((object != nil) && ([object respondsToSelector:@selector(unsignedIntegerValue)]))
	{
		result = [object unsignedIntegerValue];
	}
	
	return result;
}


- (NSString*)stringForKey:(id)key
{
	NSString* result = nil;
	
	id object = [self nonNullObjectForKey:key];
	if (object != nil)
	{
		result = object;
	}
	else
	{
		result = [NSString string];
	}
	
	return result;
}


- (NSDictionary*)dictionaryWithMappedKeys:(id(^)(id key))keyMapBlock
{
	NSMutableDictionary* result = [NSMutableDictionary dictionaryWithCapacity:[self count]];
	[self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		id mappedKey = keyMapBlock(key);
		if (mappedKey != nil)
		{
			[result setValue:obj forKey:mappedKey];
		}
		else
		{
			NSLog(@"could not map key: %@", key);
		}
	}];
	
	return result;
}


- (NSDictionary*)dictionaryWithIntegerKeys
{
	// create a temp dictionary with integer keys
	NSMutableDictionary* temp = [[NSMutableDictionary alloc] initWithCapacity:[self count]];
	[self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		[temp setObject:obj forKey:[NSNumber numberWithInteger:[key integerValue]]];
	}];
	
	// create the result dictionary
	NSDictionary* result = [NSDictionary dictionaryWithDictionary:temp];
	[temp release];
	
	return result;
}

@end
