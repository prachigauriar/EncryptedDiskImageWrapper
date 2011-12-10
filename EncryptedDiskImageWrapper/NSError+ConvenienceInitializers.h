//
//  NSError+ConvenienceInitializers.h
//  EncryptedDiskImageWrapper
//
//  Created by Prachi Gauriar on 11/13/2011.
//  Copyright (c) 2011 Prachi Gauriar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (ConvenienceInitializers)

/*!
 @abstract Constructs and returns a new error with the specified domain and code, and with a userInfo dictionary containing the specified keys and values.
 @discussion At least one key-value pair must be specified.
 
 @param domain The new error's domain
 @param code The new error's code
 @param object1 The first value to add to the new error's userInfo dictionary
 @param ... First the key for object1, then null-terminated list of alternating values and keys. If any key is nil, an NSInvalidArgumentException is raised.
 
 @return A new error object with the specified domain, code, and userInfo dictionary.
 */
+ (NSError *)errorWithDomain:(NSString *)domain code:(NSInteger)code userInfoObjectsAndKeys:(id)object1,...;

/*!
 @abstract Constructs and returns a new error with the specified domain, code, and underlying error.
 @discussion The new error's userInfo dictionary will contain a single key, NSUnderlyingErrorKey, whose value will be error.
 
 @param domain The new error's domain
 @param code The new error's code
 @param underlyingError The new error's underlying error
 
 @return A new error object with the specified domain, code, and underlying error.
 */
+ (NSError *)errorWithDomain:(NSString *)domain code:(NSInteger)code underlyingError:(NSError *)underlyingError;

@end
