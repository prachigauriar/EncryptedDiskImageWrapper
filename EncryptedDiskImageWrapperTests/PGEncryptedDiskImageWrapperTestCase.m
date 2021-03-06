//
//  PGEncryptedDiskImageWrapperTestCase.m
//  EncryptedDiskImageWrapperTests
//
//  Created by Prachi Gauriar on 11/14/2011.
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

#import "PGEncryptedDiskImageWrapperTestCase.h"

#import "NSData+Crypto.h"
#import "NSFileManager+TemporaryFiles.h"

@implementation PGEncryptedDiskImageWrapperTestCase

- (void)setUp
{
    [super setUp];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *tempDirectoryTemplate = @"PGEncryptedDiskImageWrapperTestCase.XXXXXX";
    
    masterPassword = [NSData randomlyGeneratedPassword];    
    wrapperPath = [[fileManager createTemporaryDirectoryWithTemplate:tempDirectoryTemplate error:NULL] stringByAppendingPathComponent:@"test.edi"];
    randomMountRoot = [fileManager createTemporaryDirectoryWithTemplate:tempDirectoryTemplate error:NULL];
    mountPoint = [fileManager createTemporaryDirectoryWithTemplate:tempDirectoryTemplate error:NULL];

    NSError *error = nil;

    NSDictionary *volumeOptions = [NSDictionary dictionaryWithObjectsAndKeys:@"Test Volume", PGNameVolumeOption, 
                                   [NSNumber numberWithUnsignedInteger:5], PGSizeVolumeOption, nil];
    
    PGEncryptedDiskImageWrapper *wrapper = [PGEncryptedDiskImageWrapper createEncryptedDiskImageWrapperAtPath:wrapperPath
                                                                                               masterPassword:masterPassword 
                                                                                                         user:@"user1"
                                                                                                     password:@"password1"
                                                                                                volumeOptions:volumeOptions
                                                                                                        error:&error];
    
    STAssertNotNil(wrapper, @"Failed to create wrapper with error: %@", error);
}


- (void)tearDown
{
    [[NSFileManager defaultManager] removeItemAtPath:wrapperPath error:NULL];
    [[NSFileManager defaultManager] removeItemAtPath:randomMountRoot error:NULL];
    [[NSFileManager defaultManager] removeItemAtPath:mountPoint error:NULL];
    [super tearDown];
}


- (void)testInit
{
    NSError *error = nil;    
    PGEncryptedDiskImageWrapper *wrapper = [[PGEncryptedDiskImageWrapper alloc] initWithContentsOfFile:wrapperPath 
                                                                                                  user:@"user1" 
                                                                                              password:@"password1" 
                                                                                                 error:&error];

    STAssertNotNil(wrapper, @"Failed to create wrapper");    

    STAssertNil([[PGEncryptedDiskImageWrapper alloc] initWithContentsOfFile:randomMountRoot user:@"user1" password:@"password1" error:&error], 
                @"Initializion with invalid path succeeded");

    STAssertNil([[PGEncryptedDiskImageWrapper alloc] initWithContentsOfFile:wrapperPath user:@"user1" password:@"wrongpassword" error:&error], 
                @"Initializion with invalid password succeeded");

    STAssertNil([[PGEncryptedDiskImageWrapper alloc] initWithContentsOfFile:wrapperPath user:@"wronguser" password:@"password1" error:&error], 
                @"Initializion with invalid user succeeded");
}


- (void)testAttach
{
    NSError *error = nil;
    
    PGEncryptedDiskImageWrapper *wrapper = [[PGEncryptedDiskImageWrapper alloc] initWithContentsOfFile:wrapperPath 
                                                                                                  user:@"user1" 
                                                                                              password:@"password1" 
                                                                                                 error:&error];

    // Attempt to detach while not attached
    STAssertFalse([wrapper detach:&error], @"Wrapper is not attached, but detach succeeded");
    
    // Attach at specific point
    STAssertTrue([wrapper attachAtPath:mountPoint error:&error], @"Attach failed");
    STAssertTrue([wrapper isAttached], @"Wrapper is attached, but status says otherwise");
    STAssertFalse([wrapper attachAtPath:mountPoint error:&error], @"Attach succeeded, but wrapper is already attached");
    STAssertNil([wrapper attachAtRandomSubdirectoryOfPath:randomMountRoot error:&error], @"Random attach succeeded, but wrapper is already attached");
    STAssertTrue([wrapper detach:&error], @"Detach failed");
    STAssertFalse([wrapper isAttached], @"Wrapper is detached, but status says otherwise");
    
    // Attach at random point
    STAssertNotNil([wrapper attachAtRandomSubdirectoryOfPath:randomMountRoot error:&error], @"Random attach failed");
    STAssertTrue([wrapper isAttached], @"Wrapper is attached, but status says otherwise");
    STAssertFalse([wrapper attachAtPath:mountPoint error:&error], @"Attach succeeded, but wrapper is already attached");
    STAssertNil([wrapper attachAtRandomSubdirectoryOfPath:randomMountRoot error:&error], @"Random attach succeeded, but wrapper is already attached");
    STAssertTrue([wrapper detach:&error], @"Detach failed");
    STAssertFalse([wrapper isAttached], @"Wrapper is detached, but status says otherwise");
}

    
- (void)testUserTableManagement
{
    NSError *error = nil;
    
    PGEncryptedDiskImageWrapper *wrapper = [[PGEncryptedDiskImageWrapper alloc] initWithContentsOfFile:wrapperPath 
                                                                                                  user:@"user1" 
                                                                                              password:@"password1" 
                                                                                                 error:&error];

    // Add a new user with a new password
    [wrapper setPassword:@"password2" forUser:@"user2"];
    STAssertTrue([wrapper saveUserTable], @"Failed to save user table");

    wrapper = [[PGEncryptedDiskImageWrapper alloc] initWithContentsOfFile:wrapperPath user:@"user2" password:@"password2" error:&error];
    STAssertNotNil(wrapper, @"Initialization with new user failed.");
    STAssertTrue([wrapper attachAtPath:mountPoint error:&error], @"Attach failed");
    STAssertTrue([wrapper isAttached], @"Wrapper is attached, but status says otherwise");
    STAssertTrue([wrapper detach:&error], @"Detach failed");

    // Change the new user's password
    [wrapper setPassword:@"password3" forUser:@"user2"];
    STAssertTrue([wrapper saveUserTable], @"Failed to save user table");
    
    wrapper = [[PGEncryptedDiskImageWrapper alloc] initWithContentsOfFile:wrapperPath user:@"user2" password:@"password3" error:&error];
    STAssertNotNil(wrapper, @"Initialization with new password failed.");
    STAssertTrue([wrapper attachAtPath:mountPoint error:&error], @"Attach failed");
    STAssertTrue([wrapper isAttached], @"Wrapper is attached, but status says otherwise");
    STAssertTrue([wrapper detach:&error], @"Detach failed");
    
    // Remove the user
    [wrapper removeUser:@"user2"];
    STAssertTrue([wrapper saveUserTable], @"Failed to save user table");

    wrapper = [[PGEncryptedDiskImageWrapper alloc] initWithContentsOfFile:wrapperPath user:@"user2" password:@"password2" error:&error];
    STAssertNil(wrapper, @"Initialization with invalid user succeeded.");
    wrapper = [[PGEncryptedDiskImageWrapper alloc] initWithContentsOfFile:wrapperPath user:@"user2" password:@"password3" error:&error];
    STAssertNil(wrapper, @"Initialization with invalid user succeeded.");
}

@end
