//
//  NSString+Grouping.m
//  EncryptedDiskImageWrapper
//
//  Created by Prachi Gauriar on 11/1/2011.
//  Copyright (c) 2011 Prachi Gauriar. All rights reserved.
//

#import "NSString+Grouping.h"

@implementation NSString (Grouping)

- (NSString *)stringByInterposingString:(NSString *)separator betweenSubstringsOfLength:(NSUInteger)substringLength
{
    NSAssert(substringLength > 0, @"substringLength == 0"); 
    if (substringLength > [self length]) return self;
    
    NSMutableString *separatedString = [NSMutableString stringWithString:self];
    NSUInteger groupCount = [self length] / substringLength;
    if ([self length] % substringLength) groupCount++;

    NSUInteger separatorLength = [separator length];
    for (NSUInteger i = 0; i < groupCount - 1; i++) {
        [separatedString insertString:separator atIndex:substringLength * (i + 1) + separatorLength * i];
    }
    
    return separatedString;
}

@end
