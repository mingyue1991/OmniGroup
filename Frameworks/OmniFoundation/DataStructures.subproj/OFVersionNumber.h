// Copyright 2004-2017 Omni Development, Inc. All rights reserved.
//
// This software may only be used and reproduced according to the
// terms in the file OmniSourceLicense.html, which should be
// distributed with this project and can also be found at
// <http://www.omnigroup.com/developer/sourcecode/sourcelicense/>.
//
// $Id$

#import <Foundation/NSObject.h>

NS_ASSUME_NONNULL_BEGIN

@interface OFVersionNumber : NSObject <NSCopying>

+ (OFVersionNumber *)mainBundleVersionNumber;
+ (OFVersionNumber *)userVisibleOperatingSystemVersionNumber;

// Convenience methods for testing the current operating system.  One nice thing about using these (rather than looking up the operating system and comparing it by hand) is that we can remove these methods when they become irrelevant (e.g. when we require Snow Leopard), helping us find and update any code which is unnecessarily trying to support an older operating system.
#if defined(TARGET_OS_IPHONE) && TARGET_OS_IPHONE
+ (BOOL)isOperatingSystem110OrLater;
+ (BOOL)isOperatingSystem111OrLater;
#else
+ (BOOL)isOperatingSystemHighSierraOrLater; // 10.13
+ (BOOL)isOperatingSystemSierraOrLater; // 10.12
+ (BOOL)isOperatingSystemSierraWithTouchBarOrLater; // 10.12.1
#endif

- (nullable instancetype)initWithVersionString:(NSString *)versionString;

@property(nonatomic,readonly) NSString *originalVersionString;
@property(nonatomic,readonly) NSString *cleanVersionString;
@property(nonatomic,readonly) NSString *prettyVersionString; // NB: This version string can't be parsed back into an OFVersionNumber. For display only!

@property(nonatomic,readonly) NSUInteger componentCount;
- (NSUInteger)componentAtIndex:(NSUInteger)componentIndex;

@property(nonatomic,readonly) NSUInteger majorComponent;
@property(nonatomic,readonly) NSUInteger minorComponent;
@property(nonatomic,readonly) NSUInteger bugFixComponent;

- (NSComparisonResult)compareToVersionNumber:(OFVersionNumber *)otherVersion;

- (BOOL)isAtLeast:(OFVersionNumber *)otherVersion;
- (BOOL)isAfter:(OFVersionNumber *)otherVersion;
- (BOOL)isBefore:(OFVersionNumber *)otherVersion;

@end

extern NSString * const OFVersionNumberTransformerName;

NS_ASSUME_NONNULL_END
