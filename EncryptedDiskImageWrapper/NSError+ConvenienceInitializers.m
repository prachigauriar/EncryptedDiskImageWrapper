//
//  NSError+ConvenienceInitializers.m
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

#import "NSError+ConvenienceInitializers.h"

@implementation NSError (ConvenienceInitializers)

+ (NSError *)errorWithDomain:(NSString *)domain code:(NSInteger)code userInfoObjectsAndKeys:(id)object1,...
{
    NSMutableArray *objects = [NSMutableArray array];
    NSMutableArray *keys = [NSMutableArray array];

    va_list args;
    va_start(args, object1);
    
    id object = object1;
    id key = va_arg(args, id);
    
    // If we didn't get at least one key-value pair, return nil
    if (!(object && key)) {
        va_end(args);
        return nil;
    }

    // Gather the objects and keys in pairs
    do {
        [objects addObject:object];
        [keys addObject:key];
    } while ((object = va_arg(args, id)) && (key = va_arg(args, id)));

    va_end(args);
    
    // If we didn't get the same number of objects and keys, raise an exception
    if (object && !key) [NSException raise:NSInvalidArgumentException format:@"nil key for object %@", object];

    return [NSError errorWithDomain:domain code:code userInfo:[NSDictionary dictionaryWithObjects:objects forKeys:keys]];
}


+ (NSError *)errorWithDomain:(NSString *)domain code:(NSInteger)code underlyingError:(NSError *)underlyingError
{
    return [self errorWithDomain:domain code:code userInfo:[NSDictionary dictionaryWithObject:underlyingError forKey:NSUnderlyingErrorKey]];
}

@end
