//
//  KCHMessage.h
//  ChatRoom
//
//  Created by Chia-Han Kuo on 31/10/2016.
//  Copyright © 2016 Chia-Han Kuo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KCHMessage : NSObject

@property (strong, nonatomic) NSString *uid;

@property (strong, nonatomic) NSString *roomId;

@property (strong, nonatomic) NSString *from;

@property (strong, nonatomic) NSString *type;

@property (strong, nonatomic) NSString *content;

@property (nonatomic) NSTimeInterval ts;

- (instancetype)initWithUid:(NSString *)uid
                     roomId:(NSString *)roomId
                       from:(NSString *)from
                       type:(NSString *)type
                    content:(NSString *)content
                  timestamp:(NSTimeInterval)ts;

- (instancetype)initWithUid:(NSString *)uid
                     roomId:(NSString *)roomId
                       info:(NSDictionary *)info;

- (NSComparisonResult)compare:(KCHMessage *)message;

- (NSDictionary *)dictionaryToSave;

+ (NSString *)pathOfMessagesForRoom:(NSString *)roomId;

- (NSString *)messagePath;
@end
