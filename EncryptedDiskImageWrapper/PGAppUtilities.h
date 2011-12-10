//
//  PGAppUtilities.h
//  EncryptedDiskImageWrapper
//
//  Created by Prachi Gauriar on 10/23/2011.
//  Copyright (c) 2011 Prachi Gauriar. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 @abstract Returns a URL for the application's Application Support subdirectory, creating it as necessary. 
 @discussion If the directory does not exist and could not be created, returns nil.
 
 @param applicationName The name of the application, which is used to name the subdirectory. May not be nil.
 @param domainMask The file system domain in which to put the directory. Must be either NSUserLocalDomainMask or NSLocalDomainMask.
 @param errorOut On input, a pointer to an error object. If an error occurs, this pointer is set to an actual error object containing the error
     information. You may specify nil for this parameter if you do not want the error information.
 
 @return a URL to the application's Application Support subdirectory
 */
extern NSURL *PGApplicationSupportURL(NSString *applicationName, NSSearchPathDomainMask domainMask, NSError **errorOut);


/*!
 @abstract Returns the application's current working directory.
 @discussion The current working directory is retrieved by accessing the application's PWD environment variable.
 @return The application's current working directory
 */
extern NSString *PGApplicationWorkingDirectory(void);