//
//  KCHUser.h
//  ChatRoom
//
//  Created by Chia-Han Kuo on 30/10/2016.
//  Copyright © 2016 Chia-Han Kuo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KCHUser : NSObject

@property (strong, nonatomic) NSString *uid;

@property (strong, nonatomic) NSMutableArray<NSString *> *createdRooms;

@property (strong, nonatomic) NSMutableArray<NSString *> *chatingRooms;

- (instancetype)initWithUid:(NSString *)uid
               createdRooms:(NSArray<NSString *> *)createdRooms
               chatingRooms:(NSArray<NSString *> *)chatingRooms;

- (instancetype)initWithUid:(NSString *)uid
                       info:(NSDictionary *)info;

- (NSDictionary *)dictionaryToSave;

+ (NSString *)userPath:(NSString *)uid;

- (NSString *)userPath;

- (NSString *)chatingRoomPath:(NSString *)roomId;

- (NSString *)createdRoomPath:(NSString *)roomId;

- (BOOL)syncCreatedRoomsWithChatingRooms;
@end
