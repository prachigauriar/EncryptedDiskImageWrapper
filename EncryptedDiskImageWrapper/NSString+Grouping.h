//
//  NSString+Grouping.h
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

#import <Foundation/Foundation.h>

/*!
 @abstract Additions to NSString to support the creation of logical groups within a string.
 @discussion The Grouping category of NSString adds a method that enables programmers to easily subdivide a string into logical groups separated by a 
     separator string.
 */
@interface NSString (Grouping)

/*!
 @abstract Constructs and returns a new string object by interposing the specified separator string between each adjacent substring 
     in the receiver of the specified length.
 @discussion If the receiver's length cannot be evenly divided by the specified substring length, the last group of characters after the
     separator string will have fewer characters than the substring length. If the length specified is longer than the receiver, 
     no separator strings are interposed. 
 
 @param separator The string to be interposed in the receiver's substrings
 @param substringLength The length of the substring between which to interpose the separator string
 
 @return A new string with the specified separator interposed between substrings of the specified length.
 */
- (NSString *)stringByInterposingString:(NSString *)separator betweenSubstringsOfLength:(NSUInteger)substringLength;

@end
