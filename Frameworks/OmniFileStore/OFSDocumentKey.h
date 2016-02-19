// Copyright 2014-2015 Omni Development, Inc. All rights reserved.
//
// This software may only be used and reproduced according to the
// terms in the file OmniSourceLicense.html, which should be
// distributed with this project and can also be found at
// <http://www.omnigroup.com/developer/sourcecode/sourcelicense/>.
//
// $Id$

#import <Foundation/NSObject.h>
#import <Foundation/NSData.h>

@class NSIndexSet;
@class OFSSegmentEncryptWorker;

/* The format of the wrapped data is a sequence of key slots. Each slot contains:
 - key type (1 byte)
 - key length in quads (1 byte)
 - key index (2 bytes)
 - key data (keylength*4 bytes)
 
 Any unused trailing space is filled with 0s; key type 0 is reserved to avoid ambiguity.
 
 Note that these numbers are part of the file format: don't change them! Also, don't reuse old numbers.
 */
enum OFSDocumentKeySlotType {
    SlotTypeNone                = 0,    // Trailing padding
    
    SlotTypeActiveAESWRAP       = 1,    // Currently-active AES key
    SlotTypeRetiredAESWRAP      = 2,    // Old AES key used after rollover
    
    SlotTypeActiveAES_CTR_HMAC  = 3,    // Currently-active CTR+HMAC key
    SlotTypeRetiredAES_CTR_HMAC = 4,    // Old key used after rollover
};

NS_ASSUME_NONNULL_BEGIN

/* An OFSDocumentKey represents a set of subkeys protected by a user-relevant mechanism like a passphrase. */
@interface OFSDocumentKey : NSObject

- (instancetype __nullable)initWithData:(NSData * __nullable)finfo error:(NSError **)outError;          // For reading a stored keyblob
- (instancetype __nullable)initWithAuthenticator:(OFSDocumentKey *)source error:(NSError **)outError;   // For creating a new keyblob sharing another one's password
- (NSData *)data;

@property (readonly,nonatomic) NSInteger changeCount;  // For detecting (semantically significant) changes to -data. Starts at 0 and increases. Not (currently) KVOable.

@property (readonly,nonatomic) BOOL valid;  // =YES if we have successfully derived our unwrapping key and have access to the key slots

/* Password-based encryption */
@property (readonly,nonatomic) BOOL hasPassword;
- (BOOL)deriveWithPassword:(NSString *)password error:(NSError **)outError;
- (BOOL)setPassword:(NSString *)password error:(NSError **)outError;

/* Key rollover: this updates the receiver to garbage-collect any slots not mentioned in keepThese, and if retireCurrent=YES, mark any active keys as inactive (and generate new active keys as needed). */
- (void)discardKeysExceptSlots:(NSIndexSet * __nullable)keepThese retireCurrent:(BOOL)retire generate:(enum OFSDocumentKeySlotType)tp;
@property (readonly,nonatomic) NSIndexSet *retiredKeySlots, *keySlots;

/* Return an encryption worker for the current active key slot. */
- (OFSSegmentEncryptWorker *)encryptionWorker;

// These methods are called by OFSSegmentEncryptWorker
- (NSData * __nullable)wrapFileKey:(const uint8_t *)fileKeyInfo length:(size_t)len error:(NSError **)outError;
- (ssize_t)unwrapFileKey:(const uint8_t *)wrappedFileKeyInfo length:(size_t)wrappedFileKeyInfoLen into:(uint8_t *)buffer length:(size_t)unwrappedKeyBufferLength error:(NSError **)outError;

@end

NS_ASSUME_NONNULL_END