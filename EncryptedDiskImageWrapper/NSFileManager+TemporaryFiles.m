//
//  NSFileManager+TemporaryFiles.m
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

#import "NSFileManager+TemporaryFiles.h"

@implementation NSFileManager (TemporaryFiles)

- (NSString *)createTemporaryFileWithTemplate:(NSString *)nameTemplate error:(NSError **)errorOut
{
    // Create a file name buffer
    char *fileName = strdup([[NSTemporaryDirectory() stringByAppendingPathComponent:nameTemplate] fileSystemRepresentation]);

    // Create the temporary file securely
    int fd = mkstemp(fileName);
    if (fd == -1) {
        free(fileName);
        if (errorOut) *errorOut = [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:nil];
        return nil;
    }
    
    // Be sure to close the file
    close(fd);
    
    // Return the path to the new file
    NSString *path = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:fileName length:strlen(fileName)];
    free(fileName);
    return path;
}


- (NSString *)createTemporaryDirectoryWithTemplate:(NSString *)nameTemplate error:(NSError **)errorOut
{
    // Create a directory name buffer
    char *directoryName = strdup([[NSTemporaryDirectory() stringByAppendingPathComponent:nameTemplate] fileSystemRepresentation]);

    // Create the temporary directory securely
    if (!mkdtemp(directoryName)) {
        free(directoryName);
        if (errorOut) *errorOut = [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:nil];
        return nil;
    }
    
    // Return the path to the new directory
    NSString *path = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:directoryName length:strlen(directoryName)];
    free(directoryName);
    return path;
}



@end
