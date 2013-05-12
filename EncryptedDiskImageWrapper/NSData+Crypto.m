//
//  NSData+Crypto.m
//  EncryptedDiskImageWrapper
//
//  Created by Prachi Gauriar on 10/29/2011.
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

#import "NSData+Crypto.h"

#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonKeyDerivation.h>
#import <Security/SecRandom.h>


#pragma mark Types, Constants, and Functions

NSString *const PGCommonCryptoErrorDomain = @"com.quantumlenscap.PGCommonCryptoErrorDomain";

/*!
 @abstract Computes and returns the digest of the specified data buffer.
 @discussion digest must be pre-allocated and have enough space to store the digest. Specifically, the size should be one of the
     digest length constants, whose names take the form CC_<ALGORITHM>_DIGEST_LENGTH, which are defined in CommonCrypto/CommonDigest.h.

 @param data The data for which to compute the digest of
 @param dataLength The length (in bytes) of data
 @param digest The buffer in which to store the digest. Should have enough allocated space to store the digest.
 
 @return The digest of the data in the data buffer.
 */
typedef unsigned char *CommonCryptoDigestFunction(const void *data, CC_LONG dataLength, unsigned char *digest);


/*!
 @abstract The number of random bytes used to generate a password.
 @discussion Note that this is not the length of the password itself.
 */
static const NSUInteger PGDataCryptoGeneratedPasswordRandomDataLength = 16;

// Key derivation constants
static const CCPBKDFAlgorithm PGDataCryptoPBKDFAlgorithm = kCCPBKDF2;
static const CCPseudoRandomAlgorithm PGDataCryptoPBKDFPseudoRandomAlgorithm = kCCPRFHmacAlgSHA256;    
static const NSUInteger PGDataCryptoPBKDFSaltSize = 24;
static const NSUInteger PGDataCryptoPBKDFKeyDerivationTime = 100;

// Symmetric key encryption/decryption constants
static const CCAlgorithm PGDataCryptoEncryptionAlgorithm = kCCAlgorithmAES128;
static const NSUInteger PGDataCryptoSymmetricKeySize = kCCKeySizeAES256;
static const NSUInteger PGDataCryptoBlockSize = kCCBlockSizeAES128;
static const NSUInteger PGDataCryptoInitializationVectorSize = PGDataCryptoBlockSize;


/*!
 @abstract Derives a symmetric key for the given password and salt combination.
 @discussion roundsOut may not be NULL. If *roundsOut is nil, this function will determine the appropriate number of rounds
     that are necessary to derive a key in 100ms, and use that value in key derivation. The value will also be returned indirectly 
     (and autoreleased) via *roundsOut. If *roundsOut is not nil, its unsigned int value will be used for the number of rounds.
 
 @param password The password to use to derive the symmetric key. May not be nil.
 @param salt The salt to use to derive the symmetric key. May not be nil.
 @param roundsOut A pointer to an NSNumber instance. May not be NULL, though the instance itself may be nil. If it is, returns
     the number of rounds indirectly. Otherwise, uses the instance's unsigned int value as the rounds value when deriving the key.
 
 @return A symmetric key suitiable for use in encrypting data
 */
static NSData *PGDataCryptoSymmetricKeyForPassword(NSString *password, NSData *salt, NSNumber **roundsOut) 
{   
    NSCAssert(password, @"nil password");
    NSCAssert(salt, @"nil salt");
    NSCAssert(roundsOut, @"NULL roundsOut");
    
    NSUInteger saltLength = [salt length];

    // *roundsOut points to a valid number, get the number of rounds out of it. Else, figure out the rounds count and return it indirectly.
    unsigned rounds = 0;
    if (*roundsOut) {
        rounds = [*roundsOut unsignedIntValue];
    } else {
        rounds = CCCalibratePBKDF(PGDataCryptoPBKDFAlgorithm, [password length], saltLength, PGDataCryptoPBKDFPseudoRandomAlgorithm, 
                                  PGDataCryptoSymmetricKeySize, PGDataCryptoPBKDFKeyDerivationTime);
        *roundsOut = [NSNumber numberWithUnsignedInt:rounds];
    }
    
    // Generate the symmetric key
    void *symmetricKey = malloc(PGDataCryptoSymmetricKeySize);
    if (CCKeyDerivationPBKDF(PGDataCryptoPBKDFAlgorithm, [password UTF8String], [password length], [salt bytes], saltLength, 
                             PGDataCryptoPBKDFPseudoRandomAlgorithm, rounds, symmetricKey, PGDataCryptoSymmetricKeySize) != kCCSuccess) {
        free(symmetricKey);
        return nil;
    }
    
    return [NSData dataWithBytesNoCopy:symmetricKey length:PGDataCryptoSymmetricKeySize];
}


#pragma mark

@implementation NSData (Crypto)


#pragma mark Random Data

- (id)initWithRandomDataOfLength:(NSUInteger)dataLength
{
    uint8_t *randomBytes = malloc(dataLength);
    if (SecRandomCopyBytes(kSecRandomDefault, dataLength, randomBytes) == -1) {
        free(randomBytes);
        return nil;
    }
    
    return [self initWithBytesNoCopy:randomBytes length:dataLength];
}


+ (NSData *)randomDataOfLength:(NSUInteger)dataLength
{
    return [[self alloc] initWithRandomDataOfLength:dataLength];
}


#pragma mark Password Generation

+ (NSString *)randomlyGeneratedPassword
{
    return [[self randomDataOfLength:PGDataCryptoGeneratedPasswordRandomDataLength] hexadecimalString];
}


#pragma mark Digests

- (NSData *)digestUsingCommonCryptoDigestFunction:(CommonCryptoDigestFunction)digestFunction digestLength:(NSUInteger)digestLength
{
    unsigned char *digestBuffer = malloc(digestLength);
    digestFunction([self bytes], (unsigned int)[self length], digestBuffer);
    return [NSData dataWithBytesNoCopy:digestBuffer length:digestLength];
}


- (NSData *)MD5Digest
{
    return [self digestUsingCommonCryptoDigestFunction:CC_MD5 digestLength:CC_MD5_DIGEST_LENGTH];
}


- (NSData *)SHA1Digest
{
    return [self digestUsingCommonCryptoDigestFunction:CC_SHA1 digestLength:CC_SHA1_DIGEST_LENGTH];
}


- (NSData *)SHA224Digest
{
    return [self digestUsingCommonCryptoDigestFunction:CC_SHA224 digestLength:CC_SHA224_DIGEST_LENGTH];    
}


- (NSData *)SHA256Digest
{
    return [self digestUsingCommonCryptoDigestFunction:CC_SHA256 digestLength:CC_SHA256_DIGEST_LENGTH];
}


- (NSData *)SHA384Digest 
{
    return [self digestUsingCommonCryptoDigestFunction:CC_SHA384 digestLength:CC_SHA384_DIGEST_LENGTH];    
}


- (NSData *)SHA512Digest
{
    return [self digestUsingCommonCryptoDigestFunction:CC_SHA512 digestLength:CC_SHA512_DIGEST_LENGTH];    
}


#pragma mark Encryption and Decryption

- (NSData *)encryptedDataWithPassword:(NSString *)password salt:(NSData **)saltOut rounds:(NSNumber **)roundsOut
                 initializationVector:(NSData **)initializationVectorOut error:(NSError **)errorOut
{
    NSAssert(password, @"nil password");
    NSAssert(saltOut, @"NULL salt");
    NSAssert(roundsOut, @"NULL rounds");
    NSAssert(initializationVectorOut, @"NULL initialization vector");

    // Generate a symmetric key for the password
    NSData *salt = [NSData randomDataOfLength:PGDataCryptoPBKDFSaltSize];
    NSNumber *rounds = nil;
    NSData *symmetricKey = PGDataCryptoSymmetricKeyForPassword(password, salt, &rounds);
    
    // Encrypt our data with symmetric key and an initialization vector
    NSData *initializationVector = [NSData randomDataOfLength:PGDataCryptoInitializationVectorSize];
    size_t encryptedDataBufferCapacity = [self length] + PGDataCryptoBlockSize;
    void *encryptedDataBuffer = malloc(encryptedDataBufferCapacity);
    size_t encryptedDataBufferLength = 0;
    
    int result = CCCrypt(kCCEncrypt, PGDataCryptoEncryptionAlgorithm, kCCOptionPKCS7Padding, [symmetricKey bytes], [symmetricKey length], 
                         [initializationVector bytes], [self bytes], [self length], encryptedDataBuffer, encryptedDataBufferCapacity, 
                         &encryptedDataBufferLength);
    
    // If we didn't have enough space to encrypt, reallocate encrypt to be encryptDataBufferLength bytes and try again
    if (result == kCCBufferTooSmall) {
        encryptedDataBufferCapacity = encryptedDataBufferLength;
        encryptedDataBuffer = realloc(encryptedDataBuffer, encryptedDataBufferCapacity);
        
        result = CCCrypt(kCCEncrypt, PGDataCryptoEncryptionAlgorithm, kCCOptionPKCS7Padding, [symmetricKey bytes], [symmetricKey length], 
                         [initializationVector bytes], [self bytes], [self length], encryptedDataBuffer, encryptedDataBufferCapacity, 
                         &encryptedDataBufferLength);
    }
    
    if (result != kCCSuccess) {
        if (errorOut) *errorOut = [NSError errorWithDomain:PGCommonCryptoErrorDomain code:result userInfo:nil];
        return nil;
    }
    
    *saltOut = salt;
    *roundsOut = rounds;
    *initializationVectorOut = initializationVector;
    
    return [NSData dataWithBytesNoCopy:encryptedDataBuffer length:encryptedDataBufferLength];
}


- (NSData *)decryptedDataWithPassword:(NSString *)password salt:(NSData *)salt rounds:(NSNumber *)rounds
                 initializationVector:(NSData *)initializationVector error:(NSError **)errorOut
{
    NSAssert(password, @"nil password");
    NSAssert(salt, @"nil salt");
    NSAssert(rounds, @"nil rounds");
    NSAssert(initializationVector, @"nil initialization vector");
    
    // Get the symmetric key for the password
    NSData *symmetricKey = PGDataCryptoSymmetricKeyForPassword(password, salt, &rounds);
    
    // Decrypt our data with the symmetric key and initialization vector
    size_t decryptedDataBufferCapacity = [self length] + PGDataCryptoBlockSize;
    void *decryptedDataBuffer = malloc(decryptedDataBufferCapacity);
    size_t decryptedDataBufferLength = 0;
    
    int result = CCCrypt(kCCDecrypt, PGDataCryptoEncryptionAlgorithm, kCCOptionPKCS7Padding, [symmetricKey bytes], [symmetricKey length], 
                         [initializationVector bytes], [self bytes], [self length], decryptedDataBuffer, decryptedDataBufferCapacity, 
                         &decryptedDataBufferLength);

    // If we didn't have enough space to decrypt, reallocate decryptedDataBuffer to be decryptedDataBufferLength bytes and try again
    if (result == kCCBufferTooSmall) {
        decryptedDataBufferCapacity = decryptedDataBufferLength;
        decryptedDataBuffer = realloc(decryptedDataBuffer, decryptedDataBufferCapacity);
        
        result = CCCrypt(kCCDecrypt, PGDataCryptoEncryptionAlgorithm, kCCOptionPKCS7Padding, [symmetricKey bytes], [symmetricKey length], 
                         [initializationVector bytes], [self bytes], [self length], decryptedDataBuffer, decryptedDataBufferCapacity, 
                         &decryptedDataBufferLength);
    }
    
    if (result != kCCSuccess) {
        if (errorOut) *errorOut = [NSError errorWithDomain:PGCommonCryptoErrorDomain code:result userInfo:nil];
        return nil;
    }
    
    return [NSData dataWithBytesNoCopy:decryptedDataBuffer length:decryptedDataBufferLength];
}


#pragma mark Utilities

- (NSString *)hexadecimalString
{
    const uint8_t *bytes = [self bytes];
    NSUInteger byteCount = [self length];
    
    NSMutableString *hexString = [NSMutableString stringWithCapacity:2 * byteCount];
    for (NSUInteger i = 0; i < byteCount; ++i) {
        [hexString appendFormat:@"%02x", bytes[i]];
    }
    
    return hexString;
}

@end
