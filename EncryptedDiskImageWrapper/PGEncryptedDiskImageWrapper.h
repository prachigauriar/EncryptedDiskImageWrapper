//
//  PGEncryptedVolumeWrapper.h
//  EncryptedDiskImageWrapper
//
//  Created by Prachi Gauriar on 10/25/2011.
//  Copyright (c) 2011 Prachi Gauriar. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const PGEncryptionTypeVolumeOption;
extern NSString *const PGGIDVolumeOption;
extern NSString *const PGModeVolumeOption;
extern NSString *const PGNameVolumeOption;
extern NSString *const PGSizeVolumeOption;
extern NSString *const PGUIDVolumeOption;


@interface PGEncryptedDiskImageWrapper : NSObject {    
@private
    NSMutableDictionary *userTable;
    NSString *masterPassword;    

    NSString *wrapperPath;    

    NSString *diskImagePath;
    NSString *userTablePath;

    NSString *mountPoint;    
}

@property(retain, readonly) NSString *wrapperPath;
@property(retain, readonly) NSString *mountPoint;

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
