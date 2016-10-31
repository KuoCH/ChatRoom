//
//  KCHError.m
//  ChatRoom
//
//  Created by Chia-Han Kuo on 30/10/2016.
//  Copyright © 2016 Chia-Han Kuo. All rights reserved.
//

#import "KCHError.h"

@implementation KCHError {
    NSString *descrip;
}

+ (instancetype)errorWithCode:(KCHErrorCode)code description:(NSString *)description {
    KCHError *error = [super errorWithDomain:KCH_ERROR_DOMAIN
                                        code:code userInfo:nil];

    error->descrip = description;
    return error;
}

- (NSString *)localizedDescription {
    return descrip;
}

@end
