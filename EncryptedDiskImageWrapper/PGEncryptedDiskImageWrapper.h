//
//  PGEncryptedVolumeWrapper.h
//  EncryptedDiskImageWrapper
//
//  Created by Prachi Gauriar on 10/25/2011.
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

extern NSString *const PGEncryptionTypeVolumeOption;
extern NSString *const PGGIDVolumeOption;
extern NSString *const PGModeVolumeOption;
extern NSString *const PGNameVolumeOption;
extern NSString *const PGSizeVolumeOption;
extern NSString *const PGUIDVolumeOption;


@interface PGEncryptedDiskImageWrapper : NSObject 

@property(readonly, strong) NSString *wrapperPath;
@property(readonly, strong) NSString *mountPoint;

+ (PGEncryptedDiskImageWrapper *)createEncryptedDiskImageWrapperAtPath:(NSString *)path masterPassword:(NSString *)masterPassword
                                                                  user:(NSString *)user password:(NSString *)password 
                                                         volumeOptions:(NSDictionary *)volumeOptions error:(NSError **)error;

- (id)initWithContentsOfFile:(NSString *)path user:(NSString *)user password:(NSString *)password error:(NSError **)error;

- (BOOL)attachAtPath:(NSString *)mountPoint error:(NSError **)error;
- (NSString *)attachAtRandomSubdirectoryOfPath:(NSString *)mountRoot error:(NSError **)error;
- (BOOL)detach:(NSError **)error;
- (BOOL)isAttached;

- (void)setPassword:(NSString *)password forUser:(NSString *)user;
- (void)removeUser:(NSString *)user;
- (BOOL)saveUserTable;

@end
