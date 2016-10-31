//
//  KCHMessage.m
//  ChatRoom
//
//  Created by Chia-Han Kuo on 31/10/2016.
//  Copyright © 2016 Chia-Han Kuo. All rights reserved.
//

#import "KCHMessage.h"
#define KEY_FROM @"from"
#define KEY_TYPE @"type"
#define KEY_CONTENT @"content"
#define KEY_TS @"ts"

@implementation KCHMessage

- (instancetype)initWithUid:(NSString *)uid
                     roomId:(NSString *)roomId
                       from:(NSString *)from
                       type:(NSString *)type
                    content:(NSString *)content
                  timestamp:(NSTimeInterval)ts {
    self = [super init];
    if (self) {
        self.uid = uid;
        self.roomId = roomId;
        self.from = from;
        self.type = type;
        self.content = content;
        self.ts = ts;
    }
    return self;
}

- (instancetype)initWithUid:(NSString *)uid
                     roomId:(NSString *)roomId
                       info:(NSDictionary *)info {
    self = [super init];
    if (self) {
        self.uid = uid;
        self.roomId = roomId;
        self.from = info[KEY_FROM];
        self.type = info[KEY_TYPE];
        self.content = info[KEY_CONTENT];
        self.ts = [(NSNumber *)info[KEY_TS] doubleValue];
    }
    return self;
}

- (NSComparisonResult)compare:(KCHMessage *)message {
    NSTimeInterval t1 = self.ts;
    NSTimeInterval t2 = message.ts;
    return ((t1 < t2) ? NSOrderedAscending : ((t1 > t2) ? NSOrderedDescending : [self.from compare:message.from]));
}

- (NSDictionary *)dictionaryToSave {
    return @{
             KEY_FROM: self.from,
             KEY_TYPE: self.type,
             KEY_CONTENT: self.content,
             KEY_TS: @(self.ts),
             };
}


+ (NSString *)pathOfMessagesForRoom:(NSString *)roomId {
    return [NSString stringWithFormat:@"msg/%@", roomId];
}

- (NSString *)messagePath {
    return [NSString stringWithFormat:@"msg/%@/%@", self.roomId, self.uid];
}

@end
