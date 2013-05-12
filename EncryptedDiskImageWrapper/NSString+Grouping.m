//
//  NSString+Grouping.m
//  EncryptedDiskImageWrapper
//
//  Created by Prachi Gauriar on 11/1/2011.
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

#import "NSString+Grouping.h"

@implementation NSString (Grouping)

- (NSString *)stringByInterposingString:(NSString *)separator betweenSubstringsOfLength:(NSUInteger)substringLength
{
    NSAssert(substringLength > 0, @"substringLength == 0"); 
    if (substringLength > [self length]) return self;
    
    NSUInteger groupCount = [self length] / substringLength;
    if ([self length] % substringLength) ++groupCount;

    NSMutableString *separatedString = [[NSMutableString alloc] initWithCapacity:[self length] + [separator length] * (groupCount - 1)];
    [separatedString appendString:self];
    
    NSUInteger separatorLength = [separator length];
    for (NSUInteger i = 0; i < groupCount - 1; ++i) {
        [separatedString insertString:separator atIndex:substringLength * (i + 1) + separatorLength * i];
    }
    
    return separatedString;
}

@end
