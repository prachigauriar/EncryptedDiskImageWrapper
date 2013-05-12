//
//  NSFileManager+TemporaryFiles.h
//  EncryptedDiskImageWrapper
//
//  Created by Prachi Gauriar on 10/28/2011.
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
 @abstract Additions to NSFileManager to support the convenient and secure creation of temporary files and directories.
 @discussion The TemporaryFiles category of NSFileManager adds instance methods to simplify the secure creation of temporary files and directories. 
     These methods simply make use of the mkstemp(3) and mkdtemp(3) functions. Refer to their documentation for more information. 
 */
@interface NSFileManager (TemporaryFiles)

/*!
 @abstract Securely creates a new temporary file whose name matches the specified template.
 @discussion Uses mkstemp(3) to create the file. See that function's documentation for more information on how to format the name template and what the
     temporary file's permissions will be.
 
     The file will be created inside of the temporary directory returned by NSTemporaryDirectory(). As such, the name template should only specify the
     file's name.
 
     Although mkstemp(3) creates and opens the file for read/writing, this method closes that file and does not return the file descriptor. 
 
 @param nameTemplate The name template to use to create the temporary file.
 @param errorOut On input, a pointer to an error object. If an error occurs, this pointer is set to an actual error object containing the error
     information. You may specify NULL for this parameter if you do not want the error information.
 
 @return The path to the temporary file that was created
 */
- (NSString *)createTemporaryFileWithTemplate:(NSString *)nameTemplate error:(NSError **)errorOut;

/*!
 @abstract Securely creates a new temporary directory whose name matches the specified template.
 @discussion Uses mkdtemp(3) to create the directory. See that function's documentation for more information on how to format the name template and what the
     temporary directory's permissions will be.
 
     The directory will be created inside of the temporary directory returned by NSTemporaryDirectory(). As such, the name template should only specify
     the directory's name.
 
 @param nameTemplate The name template to use to create the temporary directory.
 @param errorOut On input, a pointer to an error object. If an error occurs, this pointer is set to an actual error object containing the error
     information. You may specify NULL for this parameter if you do not want the error information.
 
 @return The path to the temporary directory that was created
 */
- (NSString *)createTemporaryDirectoryWithTemplate:(NSString *)nameTemplate error:(NSError **)errorOut;

@end
