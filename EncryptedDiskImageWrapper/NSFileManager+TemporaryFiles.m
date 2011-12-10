//
//  NSFileManager+TemporaryFiles.m
//  EncryptedDiskImageWrapper
//
//  Created by Prachi Gauriar on 10/28/2011.
//  Copyright (c) 2011 Prachi Gauriar. All rights reserved.
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
