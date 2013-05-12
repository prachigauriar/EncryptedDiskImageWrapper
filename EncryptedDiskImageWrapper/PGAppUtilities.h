//
//  PGAppUtilities.h
//  EncryptedDiskImageWrapper
//
//  Created by Prachi Gauriar on 10/23/2011.
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