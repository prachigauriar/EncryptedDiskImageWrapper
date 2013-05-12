//
//  NSError+ConvenienceInitializers.h
//  EncryptedDiskImageWrapper
//
//  Created by Prachi Gauriar on 11/13/2011.
//  Copyright (c) 2011 Prachi Gauriar.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
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
