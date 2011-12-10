//
//  NSError+ConvenienceInitializers.m
//  EncryptedDiskImageWrapper
//
//  Created by Prachi Gauriar on 11/13/2011.
//  Copyright (c) 2011 Prachi Gauriar. All rights reserved.
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
