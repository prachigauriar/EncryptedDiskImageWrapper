//
//  PGErrors.h
//  EncryptedDiskImageWrapper
//
//  Created by Prachi Gauriar on 11/1/2011.
//  Copyright (c) 2011 Prachi Gauriar. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const PGErrorDomain;

extern NSString *const PGTaskStandardErrorKey;

enum {
    // hdiutil-related errors
    PGEncryptedDiskImageWrapperCreationError,
    PGEncryptedDiskImageWrapperAttachmentError,
    PGEncryptedDiskImageWrapperDetachmentError,
    
    // Authentication errors
    PGEncryptedDiskImageWrapperAuthenticationError,
    
    // User table errors
    PGEncryptedDiskImageWrapperMalformedUserTableError,
    PGEncryptedDiskImageWrapperUserTableWriteFailedError,
}; 
