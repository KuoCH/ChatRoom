//
//  KCHError.h
//  ChatRoom
//
//  Created by Chia-Han Kuo on 30/10/2016.
//  Copyright © 2016 Chia-Han Kuo. All rights reserved.
//

#import <Foundation/Foundation.h>
#define KCH_ERROR_DOMAIN @"KCHErrorDomain"

typedef enum : NSUInteger {
    KCHErrorCodeInvalidPassword = 34001,
    KCHErrorCodeOutOfQuota = 34002,
} KCHErrorCode;

@interface KCHError : NSError

+ (instancetype)errorWithCode:(KCHErrorCode)code description:(NSString *)description;

@end
