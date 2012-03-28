//
//  ContainerAdditions.h
//
//  Copyright 2011 Mutual Mobile. All rights reserved.
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

#import <Foundation/Foundation.h>


@interface NSArray (ContainerAdditions)
+ (id)arrayWithContentsOfPropertyListNamed:(NSString*)propertyListName;

// lastIndex returns the index of the last item in the array
// if the array contains no items, return NSNotFound
- (NSUInteger)lastIndex;
@end


@interface NSDictionary (ContainerAdditions)
+ (id)dictionaryWithContentsOfPropertyListNamed:(NSString*)propertyListName;

// containsKey: returns YES if the receiver contains a value for the given key, or NO if the receiver does not contain a value for the given key
- (BOOL)containsKey:(id)key;

// containsKeys: returns YES if the receiever contains all the keys passed in as arguments, or NO if the receiver does not contain one or more of the provided keys
- (BOOL)containsKeys:(id)keys, ... NS_REQUIRES_NIL_TERMINATION;
- (BOOL)containsKeysInArray:(NSArray*)keys;

// boolForKey: returns the BOOL value for the key if the key exists, or NO if the reciever does not contain the key or contains NSNull
- (BOOL)boolForKey:(id)key;

// dictionaryForKey: returns the dictionary value for the key if the key exists, or nil if the reciever does not contain the key or contains NSNull
- (NSDictionary*)dictionaryForKey:(id)key;

// doubleForKey: returns the double value for the key if the key exists, or 0.0 if the reciever does not contain the key or contains NSNull
- (double)doubleForKey:(id)key;

// integerForKey: returns the integer value for the key if the key exists, or 0 if the reciever does not contain the key or contains NSNull
- (NSInteger)integerForKey:(id)key;

// stringForKey: returns the string value for the key if the key exists, or nil if the reciever does not contain the key or contains NSNull
- (NSString*)stringForKey:(id)key;

// unsignedIntegerForKey: returns the unsigned integer value for the key if the key exists, or 0 if the reciever does not contain the key or contains NSNull
- (NSUInteger)unsignedIntegerForKey:(id)key;

// dictionaryWithMappedKeys: creates a new dictionary with all keys mapped to new keys using a block
- (NSDictionary*)dictionaryWithMappedKeys:(id(^)(id key))keyMapBlock;

// dictionaryWithIntegerKeys creates a new dictionary with all keys converted to integers (NSNumber)
- (NSDictionary*)dictionaryWithIntegerKeys;
@end
