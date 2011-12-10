//
//  PGAppUtilities.m
//  EncryptedDiskImageWrapper
//
//  Created by Prachi Gauriar on 10/23/2011.
//  Copyright (c) 2011 Prachi Gauriar. All rights reserved.
//

#import "PGAppUtilities.h"

NSURL *PGApplicationSupportURL(NSString *applicationName, NSSearchPathDomainMask domainMask, NSError **errorOut) 
{
    NSCAssert(applicationName, @"nil applicationName");
    NSCAssert1(domainMask == NSUserDomainMask || domainMask == NSLocalDomainMask, @"domainMask (%d) is not user or local domain.", domainMask);
    
    NSError *error = nil;

    NSFileManager *defaultFileManager = [NSFileManager defaultManager];
    NSURL *overallAppSupportURL = [defaultFileManager URLForDirectory:NSApplicationSupportDirectory inDomain:domainMask 
                                                    appropriateForURL:nil create:NO error:&error];
    if (!overallAppSupportURL) {
        if (errorOut && error) *errorOut = error;
        return nil;
    }
    
    NSURL *appSupportURL = [overallAppSupportURL URLByAppendingPathComponent:applicationName isDirectory:YES];
    if (![defaultFileManager createDirectoryAtURL:appSupportURL withIntermediateDirectories:YES attributes:nil error:&error]) {
        if (errorOut && error) *errorOut = error;
        return nil;
    }        
    
    return appSupportURL;
}


NSString *PGApplicationWorkingDirectory(void)
{
    return [[[NSProcessInfo processInfo] environment] objectForKey:@"PWD"];
}
