//
//  PGEncryptedVolumeWrapper.m
//  EncryptedDiskImageWrapper
//
//  Created by Prachi Gauriar on 10/25/2011.
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

#import "PGEncryptedDiskImageWrapper.h"

#import "NSData+Crypto.h"
#import "NSError+ConvenienceInitializers.h"
#import "NSFileManager+TemporaryFiles.h"

#import "PGAppUtilities.h"
#import "PGErrors.h"


#pragma mark Types and Constants

/*! 
 @abstract Constants for indicating what verb hdiutil should perfom. 
 @discussion These constants are only used with the +executeHDIUtilTaskWithVerb:arguments:password:result:error: method.
 */
typedef NS_ENUM(NSUInteger, PGHDIUtilVerb) {
    /*! @abstract The create verb, which instructs hdiutil to creates a disk image. */
    PGHDIUtilCreateVerb = 1,
    
    /*! @abstract The attach verb, which instructs hdiutil to attach a disk image and mount its volumes. */
    PGHDIUtilAttachVerb,
    
    /*! @abstract The detach verb, which instructs hdiutil to unmount a disk image's volumes and detach it. */
    PGHDIUtilDetachVerb
};


NSString *const PGEncryptionTypeVolumeOption = @"EncryptionType";
NSString *const PGGIDVolumeOption = @"GID";
NSString *const PGModeVolumeOption = @"Mode";
NSString *const PGUIDVolumeOption = @"UID";
NSString *const PGNameVolumeOption = @"VolumeName";
NSString *const PGSizeVolumeOption = @"VolumeSize";

/*! @abstract The user table entry key whose value corresponds to the entry's user. */
static NSString *const PGUserUserTableEntryKey = @"User";

/*! @abstract The user table entry key whose value corresponds to the entry's salt. */
static NSString *const PGSaltUserTableEntryKey = @"Salt";

/*! @abstract The user table entry key whose value corresponds to the entry's rounds value. */
static NSString *const PGRoundsUserTableEntryKey = @"Rounds";

/*! @abstract The user table entry key whose value corresponds to the entry's initialization vector. */
static NSString *const PGInitializationVectorUserTableEntryKey = @"IV";

/*! @abstract The user table entry key whose value corresponds to the entry's secret. */
static NSString *const PGSecretUserTableEntryKey = @"Secret";

/*! @abstract The name of the encrypted disk image file inside the encrypted disk image wrapper's bundle. */
static NSString *const PGEncryptedDiskImageFilename = @"EncryptedDiskImage.sparsebundle";

/*! @abstract The name of the user table file inside the encrypted disk image wrapper's bundle. */
static NSString *const PGUserTableFilename = @"UserTable.plist";


#pragma mark - Private Methods Interface 

@interface PGEncryptedDiskImageWrapper ()

/*!
 @abstract Executes hdiutil with the specified verb and arguments. 
 @discussion The arguments specified should not contain the verb string, i.e., "create", "attach", or "detach", as these will automatically be added to the 
     argument list based on the verb specified. In addition, for the PGHDIUtilCreateVerb and PGHDIUtilAttachVerb verbs, "-plist" and "-stdinpass" will 
     automatically be added to the argument list. As one might expect, in these cases the specified password is passed to hdiutil via its standard input
     pipe, and hdiutil's output as a property list can be retrieved indirectly using the resultOut parameter. If the verb is PGHDIUtilDetachVerb, the
     password and result parameters are ignored.
 
 @param verb The verb that hdiutil should perform.
 @param arguments The arguments to be passed to hdiutil, excluding the verb, "-stdinpass", and "-plist". May not be nil.
 @param password The password to pass to hdiutil. May only be nil if the verb is PGHDIUtilDetachVerb.
 @param resultOut On input, a pointer to an NSDictionary object. Upon successful completion, points the hdiutil's output as a dictionary object. You 
     may specify NULL for this parameter if you do not want the result dictionary.
 @param errorOut On input, a pointer to an error object. If an error occurs, this pointer is set to an actual error object containing the error
     information. You may specify NULL for this parameter if you do not want the error information.
 
 @return A boolean indicating whether the task completed executing successfully. 
 */
+ (BOOL)executeHDIUtilTaskWithVerb:(PGHDIUtilVerb)verb arguments:(NSArray *)arguments password:(NSString *)password 
                            result:(NSDictionary **)resultOut error:(NSError **)errorOut;

/*!
 @abstract Reads the options supplied in the volume options directory and returns an array of arguments suitable to pass to an hdiutil task.
 @discussion This method is only userful for creating a disk image. The dictionary must contain the PGSizeVolumeOption key, and its value must
     respond to the -unsignedIntegerValue message.
 
 @param volumeOptions The volume options dictionary. May not be nil.
 
 @return An array of arguments suitable to pass to an hdiutil task
 */
+ (NSMutableArray *)hdiutilTaskArgumentsForVolumeOptions:(NSDictionary *)volumeOptions;

/*!
 @abstract Returns a dictionary to be used as the value for the user's key in an encrypted disk image's user table. 
 @discussion To create the dictionary, this method encrypts the master password using the user's password. The dictionary contains the user's name,
     the encrypted master password, and various metadata required to decrypt the master password later. See the PG*UserTableEntryKey constants for more 
     information.
 
 @param masterPassword The master password for the user table's corresponding encrypted disk image. May not be nil.
 @param user The user's name. May not be nil.
 @param password The user's password. May not be nil.
 
 @return A dictionary to be used as the value for the user's key in an encrypted disk image's user table.
 */
+ (NSDictionary *)userTableEntryForMasterPassword:(NSString *)masterPassword user:(NSString *)user password:(NSString *)password;

@property(readwrite, copy) NSString *masterPassword;
@property(readwrite, strong) NSString *mountPoint;
@property(readwrite, strong) NSMutableDictionary *userTable;
@property(readwrite, strong) NSString *wrapperPath;

@end


#pragma mark - Implementation

@implementation PGEncryptedDiskImageWrapper {
    NSString *_wrapperPath;
    NSString *_diskImagePath;
    NSString *_userTablePath;
}


+ (PGEncryptedDiskImageWrapper *)createEncryptedDiskImageWrapperAtPath:(NSString *)path
                                                        masterPassword:(NSString *)masterPassword
                                                                  user:(NSString *)user
                                                              password:(NSString *)password
                                                         volumeOptions:(NSDictionary *)volumeOptions
                                                                 error:(NSError **)errorOut
{
    NSError *error = nil;
    
    // Create a temp wrapper directory in which to generate our wrapper
    NSString *tempWrapperPath = [[NSFileManager defaultManager] createTemporaryDirectoryWithTemplate:@"PGEncryptedDiskImageWrapper.XXXXXX" error:&error];
    if (!tempWrapperPath) {
        if (errorOut) {
            *errorOut = [NSError errorWithDomain:PGErrorDomain code:PGEncryptedDiskImageWrapperCreationError userInfoObjectsAndKeys:error,
                         NSUnderlyingErrorKey, NSLocalizedString(@"Failed to create the encrypted disk image wrapper directory.", nil),
                         NSLocalizedDescriptionKey, nil];
        }
        return nil;
    }
    
    // Create the user table
    NSMutableDictionary *userTable = [[NSMutableDictionary alloc] init];
    [userTable setObject:[self userTableEntryForMasterPassword:masterPassword user:user password:password] forKey:user];
    if (![userTable writeToFile:[tempWrapperPath stringByAppendingPathComponent:PGUserTableFilename] atomically:YES]) {
        if (errorOut) *errorOut = [NSError errorWithDomain:PGErrorDomain code:PGEncryptedDiskImageWrapperCreationError userInfoObjectsAndKeys:
                         NSLocalizedString(@"Failed to create the encrypted disk image's user table.", nil), NSLocalizedDescriptionKey, nil];
        return nil;
    }

    // Create the encrypted disk image
    NSMutableArray *args = [self hdiutilTaskArgumentsForVolumeOptions:volumeOptions];
    [args insertObject:[tempWrapperPath stringByAppendingPathComponent:PGEncryptedDiskImageFilename] atIndex:0];
    if (![self executeHDIUtilTaskWithVerb:PGHDIUtilCreateVerb arguments:args password:masterPassword result:NULL error:&error]) {
        if (errorOut) *errorOut = [NSError errorWithDomain:PGErrorDomain code:PGEncryptedDiskImageWrapperCreationError userInfoObjectsAndKeys:error,
                                   NSUnderlyingErrorKey, NSLocalizedString(@"Failed to create the encrypted disk image.", nil), NSLocalizedDescriptionKey, 
                                   nil];
        return nil;
    }
    
    // Move the disk image wrapper to URL
    if (![[NSFileManager defaultManager] moveItemAtPath:tempWrapperPath toPath:path error:&error]) {
        if (errorOut) *errorOut = [NSError errorWithDomain:PGErrorDomain code:PGEncryptedDiskImageWrapperCreationError userInfoObjectsAndKeys: error, 
                                   NSUnderlyingErrorKey, NSLocalizedString(@"Failed to save the encrypted disk image wrapper.", nil), 
                                   NSLocalizedDescriptionKey, nil];
        return nil;
    }

    return [[self alloc] initWithContentsOfFile:path user:user password:password error:errorOut];
}


// There’s no meaningful default values for our designated initializer, so we just don't recognize the -init message.
- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}


- (id)initWithContentsOfFile:(NSString *)path user:(NSString *)user password:(NSString *)password error:(NSError **)errorOut
{
    if (!(self = [super init])) return nil;

    [self setWrapperPath:path];    
    _userTablePath = [_wrapperPath stringByAppendingPathComponent:PGUserTableFilename];
    _diskImagePath = [_wrapperPath stringByAppendingPathComponent:PGEncryptedDiskImageFilename];

    // If the user table or disk image is missing, return an error
    if (![[NSFileManager defaultManager] fileExistsAtPath:_userTablePath] || ![[NSFileManager defaultManager] fileExistsAtPath:_diskImagePath]) {
        if (errorOut) *errorOut = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileNoSuchFileError userInfo:nil];
        return nil;
    }
    
    // Get the user table
    [self setUserTable:[[NSMutableDictionary alloc] initWithContentsOfFile:_userTablePath]];
    NSDictionary *userEntry = [_userTable objectForKey:user];
    if (!userEntry) {
        if (errorOut) *errorOut = [NSError errorWithDomain:PGErrorDomain code:PGEncryptedDiskImageWrapperAuthenticationError userInfoObjectsAndKeys:
                                   NSLocalizedString(@"Bad user name or password.", nil), NSLocalizedDescriptionKey, nil];
        return nil;
    }
    
    // Get the data necessary to decrypt the master password
    NSData *secret = [userEntry objectForKey:PGSecretUserTableEntryKey];
    NSData *salt = [userEntry objectForKey:PGSaltUserTableEntryKey];
    NSNumber *rounds = [userEntry objectForKey:PGRoundsUserTableEntryKey];
    NSData *iv = [userEntry objectForKey:PGInitializationVectorUserTableEntryKey];
    if (!(salt && rounds && iv && secret)) {
        if (errorOut) *errorOut = [NSError errorWithDomain:PGErrorDomain code:PGEncryptedDiskImageWrapperMalformedUserTableError userInfo:nil];
        return nil;
    }
        
    // Attempt to decrypt the master password
    NSError *error = nil;
    NSData *masterPasswordData = [secret decryptedDataWithPassword:password salt:salt rounds:rounds initializationVector:iv error:&error];
    if (!masterPasswordData) {
        if (errorOut) *errorOut = [NSError errorWithDomain:PGErrorDomain code:PGEncryptedDiskImageWrapperAuthenticationError userInfoObjectsAndKeys:
                                   error, NSUnderlyingErrorKey, NSLocalizedString(@"Bad user name or password.", nil), NSLocalizedDescriptionKey, nil];
        return nil;
    }
    
    // If we were unable to determine the master password, something went wrong, so return nil
    [self setMasterPassword:[[NSString alloc] initWithData:masterPasswordData encoding:NSUTF8StringEncoding]];
    return _masterPassword ? self : nil;
}



#pragma mark Mounting and Unmounting

- (BOOL)attachAtPath:(NSString *)mountPath error:(NSError **)errorOut
{
    if ([self isAttached]) return NO;
    
    NSError *error = nil;
    
    NSDictionary *result = nil; 
    NSArray *args = [NSArray arrayWithObjects:_diskImagePath, @"-nobrowse", @"-mountpoint", mountPath, nil];
    if (![[self class] executeHDIUtilTaskWithVerb:PGHDIUtilAttachVerb arguments:args password:_masterPassword result:&result error:&error]) {
        if (errorOut) *errorOut = [NSError errorWithDomain:PGErrorDomain code:PGEncryptedDiskImageWrapperAttachmentError userInfoObjectsAndKeys:error, 
                                   NSUnderlyingErrorKey, NSLocalizedString(@"Failed to attach disk image.", nil), NSLocalizedDescriptionKey, nil];
        return NO;
    }
    
    for (NSDictionary *systemEntityDictionary in [result objectForKey:@"system-entities"]) {
        NSString *entityMountPoint = [systemEntityDictionary objectForKey:@"mount-point"];
        if (entityMountPoint) {
            [self setMountPoint:entityMountPoint];
            break;
        }
    }
    
    return [self isAttached];
}


- (NSString *)attachAtRandomSubdirectoryOfPath:(NSString *)mountRoot error:(NSError **)errorOut
{
    if ([self isAttached]) return nil;

    NSError *error = nil;
    
    NSArray *args = [NSArray arrayWithObjects:_diskImagePath, @"-nobrowse", @"-mountrandom", mountRoot, nil];
    
    NSDictionary *result = nil; 
    if (![[self class] executeHDIUtilTaskWithVerb:PGHDIUtilAttachVerb arguments:args password:_masterPassword result:&result error:&error]) {
        if (errorOut) *errorOut = [NSError errorWithDomain:PGErrorDomain code:PGEncryptedDiskImageWrapperAttachmentError userInfoObjectsAndKeys:error, 
                                   NSUnderlyingErrorKey, NSLocalizedString(@"Failed to attach disk image.", nil), NSLocalizedDescriptionKey, nil];
        return nil;
    }
    
    for (NSDictionary *systemEntityDictionary in [result objectForKey:@"system-entities"]) {
        NSString *entityMountPoint = [systemEntityDictionary objectForKey:@"mount-point"];
        if (entityMountPoint) {
            [self setMountPoint:entityMountPoint];
            break;
        }
    }
    
    return _mountPoint;
}


- (BOOL)detach:(NSError **)errorOut
{
    if (![self isAttached]) return NO;
    
    NSError *error = nil;
    if (![[self class] executeHDIUtilTaskWithVerb:PGHDIUtilDetachVerb arguments:[NSArray arrayWithObject:_mountPoint] password:nil result:NULL error:&error]) {
        if (errorOut) *errorOut = [NSError errorWithDomain:PGErrorDomain code:PGEncryptedDiskImageWrapperAttachmentError userInfoObjectsAndKeys:error, 
                                   NSUnderlyingErrorKey, NSLocalizedString(@"Failed to detach disk image.", nil), NSLocalizedDescriptionKey, nil];
        return NO;
    }
    
    [self setMountPoint:nil];
    
    return YES;
}


- (BOOL)isAttached
{
    return _mountPoint != nil;
}


#pragma mark User Table Management

- (void)setPassword:(NSString *)password forUser:(NSString *)user
{
    [_userTable setObject:[[self class] userTableEntryForMasterPassword:_masterPassword user:user password:password] forKey:user];
}


- (void)removeUser:(NSString *)user
{
    [_userTable removeObjectForKey:user];
}


- (BOOL)saveUserTable
{
    return [_userTable writeToFile:_userTablePath atomically:YES];
}


#pragma mark Private Methods


+ (BOOL)executeHDIUtilTaskWithVerb:(PGHDIUtilVerb)verb arguments:(NSArray *)arguments password:(NSString *)masterPassword 
                            result:(NSDictionary **)resultOut error:(NSError **)errorOut
{
    NSAssert(verb == PGHDIUtilCreateVerb || verb == PGHDIUtilAttachVerb || verb == PGHDIUtilDetachVerb, @"Invalid verb %lu", verb);
    NSAssert(verb == PGHDIUtilDetachVerb || masterPassword, @"Master password required for verb (%lu)", verb);
    
    NSTask *hdiutil = [[NSTask alloc] init];
    [hdiutil setLaunchPath:@"/usr/bin/hdiutil"];
    [hdiutil setStandardInput:[NSPipe pipe]];
    [hdiutil setStandardOutput:[NSPipe pipe]];
    [hdiutil setStandardError:[NSPipe pipe]];

    NSMutableArray *args = [NSMutableArray arrayWithArray:arguments];
    
    if (verb == PGHDIUtilDetachVerb) {
        [args insertObject:@"detach" atIndex:0];
    } else {
        [args insertObject:(verb == PGHDIUtilAttachVerb ? @"attach" : @"create") atIndex:0];
        [args addObject:@"-plist"];
        [args addObject:@"-stdinpass"];
        
        // Convert the password to a C string so that it's null-terminated
        const char *passwordCString = [masterPassword cStringUsingEncoding:NSUTF8StringEncoding];
        
        // Write everything to stdin before we even launch
        [[[hdiutil standardInput] fileHandleForWriting] writeData:[NSData dataWithBytes:passwordCString length:[masterPassword length] + 1]];
    }

    // Let the app finish executing, then read from its standard input and error pipes
    [hdiutil setArguments:args];
    [hdiutil launch];
    [hdiutil waitUntilExit];

    if ([hdiutil terminationStatus] != 0) {
        NSData *stderrData = [[[hdiutil standardError] fileHandleForReading] readDataToEndOfFile];
        
        if (errorOut) {
            NSString *stderrString = [[NSString alloc] initWithData:stderrData encoding:NSUTF8StringEncoding];
            *errorOut = [NSError errorWithDomain:PGErrorDomain code:PGEncryptedDiskImageWrapperAuthenticationError userInfoObjectsAndKeys:
                         stderrString, PGTaskStandardErrorKey, NSLocalizedString(@"Error executing hdiutil", nil), NSLocalizedDescriptionKey, nil];
        }
        return NO;
    }

    if (verb != PGHDIUtilDetachVerb && resultOut) {
        NSData *hdiutilStandardOutputData = [[[hdiutil standardOutput] fileHandleForReading] readDataToEndOfFile];
        *resultOut = [NSPropertyListSerialization propertyListWithData:hdiutilStandardOutputData options:NSPropertyListImmutable format:NULL error:errorOut];
    }

    return YES;
}


+ (NSMutableArray *)hdiutilTaskArgumentsForVolumeOptions:(NSDictionary *)volumeOptions
{
    NSNumber *volumeSize = [volumeOptions objectForKey:PGSizeVolumeOption];
    NSAssert(volumeSize, @"nil volume size");

    // Default arguments
    NSMutableArray *arguments = [[NSMutableArray alloc] init];
    [arguments addObject:@"-megabytes"];
    [arguments addObject:[NSString stringWithFormat:@"%lu", [volumeSize unsignedIntegerValue]]];
    [arguments addObject:@"-type"];
    [arguments addObject:@"SPARSEBUNDLE"];
    [arguments addObject:@"-fs"];
    [arguments addObject:@"HFS+J"];
        
    NSString *encryptionType = [volumeOptions objectForKey:PGEncryptionTypeVolumeOption];
    if (encryptionType) {
        [arguments addObject:@"-encryption"];
        [arguments addObject:encryptionType];
    }
    
    NSString *volumeName = [volumeOptions objectForKey:PGNameVolumeOption];
    if (volumeName) {
        [arguments addObject:@"-volname"];
        [arguments addObject:volumeName];
    }

    NSString *uid = [volumeOptions objectForKey:PGUIDVolumeOption];
    if (uid) {
        [arguments addObject:@"-uid"];
        [arguments addObject:uid];
    }
    
    NSString *gid = [volumeOptions objectForKey:PGGIDVolumeOption];
    if (gid) {
        [arguments addObject:@"-gid"];
        [arguments addObject:gid];
    }
    
    NSString *mode = [volumeOptions objectForKey:PGModeVolumeOption];
    if (mode) {
        [arguments addObject:@"-mode"];
        [arguments addObject:mode];
    }
        
    return arguments;
}


+ (NSDictionary *)userTableEntryForMasterPassword:(NSString *)masterPassword user:(NSString *)user password:(NSString *)password
{
    NSAssert(masterPassword, @"nil master password");
    NSAssert(user, @"nil user");
    NSAssert(password, @"nil user");
    
    NSData *salt = nil;
    NSNumber *rounds = nil;
    NSData *iv = nil;
    NSData *masterPasswordData = [masterPassword dataUsingEncoding:NSUTF8StringEncoding];
    NSData *secret = [masterPasswordData encryptedDataWithPassword:password salt:&salt rounds:&rounds initializationVector:&iv error:NULL];
    
    return [NSDictionary dictionaryWithObjectsAndKeys:user, PGUserUserTableEntryKey, salt, PGSaltUserTableEntryKey, 
            rounds, PGRoundsUserTableEntryKey, iv, PGInitializationVectorUserTableEntryKey,
            secret, PGSecretUserTableEntryKey, nil];
}

@end
