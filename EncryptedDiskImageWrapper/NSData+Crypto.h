//
//  NSData+Crypto.h
//  EncryptedDiskImageWrapper
//
//  Created by Prachi Gauriar on 10/29/2011.
//  Copyright (c) 2011 Prachi Gauriar. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 @abstract The error domain used when errors originate in the CommonCrypto functions.
 */
extern NSString *const PGCommonCryptoErrorDomain;

/*!
 @abstract Additions to NSData to support cryptography.
 @discussion The Crypto category of NSData adds methods of general utility in cryptographic applications. It adds methods for secure random
     number and password generation, MD5 and SHA digests, and AES symmetric key cryptography.
 
     All cryptographic methods are implemented using a combination of the Security Framework and Common Crypto library.
 */
@interface NSData (Crypto)


/*!
 @abstract Returns a newly initialized data object containing the specified number of cryptographically secure random bytes.
 @discussion The random bytes are generated using SecRandomCopyBytes(). 
 @param dataLength The number of random bytes to be generated
 @return A newly initialized data object containing the specified number of random bytes
 */
- (id)initWithRandomDataOfLength:(NSUInteger)dataLength;

/*!
 @abstract Constructs and returns a data object containing the specified number of cryptographically secure random bytes.
 @discussion The random bytes are generated using SecRandomCopyBytes().
 @param dataLength The number of random bytes to be generated
 @return A newly initialized data object containing the specified number of random bytes
 */
+ (NSData *)randomDataOfLength:(NSUInteger)dataLength;

/*!
 @abstract Generates a password using cryptographically secure random byte generation.
 @discussion The password is generated by randomly generating 16 bytes of data, which is then converted into a 32 character string. 16 bytes of random
     data gives 128 bits of entropy, so there are 340282366920938463463374607431768211456 different passwords that can be generated. If this is 
     insufficient, simply invoke [[NSData randomDataOfLength:n] hexadecimalString], where n is a number large enough to meet your cryptographic needs.
 @return A randomly generated password with 128 bits of entropy
 */
+ (NSString *)randomlyGeneratedPassword;

/*!
 @abstract Returns the MD5 digest of the receiver.
 @return The MD5 digest of the receiver
 */
- (NSData *)MD5Digest;

/*!
 @abstract Returns the SHA-1 digest of the receiver.
 @return The SHA-1 digest of the receiver
 */
- (NSData *)SHA1Digest;

/*!
 @abstract Returns the SHA-224 digest of the receiver.
 @return The SHA-224 digest of the receiver
 */
- (NSData *)SHA224Digest;

/*!
 @abstract Returns the SHA-256 digest of the receiver.
 @return The SHA-256 digest of the receiver
 */
- (NSData *)SHA256Digest;

/*!
 @abstract Returns the SHA-384 digest of the receiver.
 @return The SHA-384 digest of the receiver
 */
- (NSData *)SHA384Digest;

/*!
 @abstract Returns the SHA-512 digest of the receiver.
 @return The SHA-512 digest of the receiver
 */
- (NSData *)SHA512Digest;

/*!
 @abstract Constructs a new data object containing the receiver's data encrypted using the AES-256 symmetric key encryption algorithm.
 @discussion Encryption is done by first deriving a symmetric key using the provided password, a randomly generated salt, and a number of rounds. The 
     number of rounds is chosen such that symmetric key derivation will take 100ms, thus introducing a penalty for attempting to guess a password. After 
     the symmetric key has been derived, it is used with a randomly generated initialization vector to encrypt the receiver's data. 
 
     In order to subsequently decrypt the result of this method, you must use the same password, salt, rounds value, and initialization vector. As such,
     the salt, rounds, and initialization vector are returned indirectly.
 
 @param password The password to use to encrypt the data. May not be nil.
 @param saltOut On input, a pointer to an NSData object. Upon successful completion, points to the randomly generated salt used during symmetric
     key derivation. May not be NULL.
 @param roundsOut On input, a pointer to an NSNumber object. Upon successful completion, points to the rounds value used during symmetric key 
     derivation. May not be NULL.
 @param initializationVectorOut On input, a pointer to an NSData object. Upon successful completion, points to the randomly generated initialization
     vector used during encryption. May not be NULL.
 @param errorOut On input, a pointer to an error object. If an error occurs, this pointer is set to an actual error object containing the error
     information. You may specify NULL for this parameter if you do not want the error information.
 
 @return A new data object containing the receiver's data encrypted with AES-256 encryption.
 */
- (NSData *)encryptedDataWithPassword:(NSString *)password 
                                 salt:(NSData **)saltOut
                               rounds:(NSNumber **)roundsOut
                 initializationVector:(NSData **)initializationVectorOut 
                                error:(NSError **)errorOut;

/*!
 @abstract Constructs a new data object containing the receiver's data decrypted using the AES-256 symmetric key encryption algorithm.
 @discussion Decryption is done by first deriving a symmetric key using the provided password, salt, and rounds count. Once the symmetric key has been
     successfully derived, it is used with the provided initialization vector to decrypt the receiver's data.
     
     The same password, salt, rounds value, and initialization vector that were used to encrypt the data must be used to decrypt it; otherwise,
     decryption will fail.
 
 @param password The password to use to encrypt the data. May not be nil.
 @param salt The randomly generated salt used to generate the symmetric encryption key. May not be nil.
 @param rounds The rounds value used to generate the symmetric encryption key. May not be nil.
 @param initializationVector The randomly generated initialization vector used to encrypt the data. May not be nil.
 @param errorOut On input, a pointer to an error object. If an error occurs, this pointer is set to an actual error object containing the error
 information. You may specify NULL for this parameter if you do not want the error information.
 
 @return A new data object containing the receiver's data decrypted using AES-256 encryption.
 */
- (NSData *)decryptedDataWithPassword:(NSString *)password 
                                 salt:(NSData *)salt 
                               rounds:(NSNumber *)rounds
                 initializationVector:(NSData *)initializationVector 
                                error:(NSError **)errorOut;

/*!
 @abstract Returns a representation of the receiver's data as a lowercase hexadecimal string.
 @discussion The string does not contain a "0x" prefix.
 @return A lowercase hexadecimal string representation of the receiver's data
 */
- (NSString *)hexadecimalString;

@end
