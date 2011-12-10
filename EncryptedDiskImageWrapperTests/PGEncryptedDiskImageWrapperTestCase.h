//
//  SpinaServerTestCases.h
//  SpinaServerTestCases
//
//  Created by Prachi Gauriar on 11/14/2011.
//  Copyright (c) 2011 Prachi Gauriar. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "PGEncryptedDiskImageWrapper.h"

@interface PGEncryptedDiskImageWrapperTestCase : SenTestCase
{
    NSString *masterPassword;
    NSString *wrapperPath;
    NSString *mountPoint;
    NSString *randomMountRoot;
}

- (void)testInit;
- (void)testAttach;
- (void)testUserTableManagement;

@end
