//
//  KCHRoom.h
//  ChatRoom
//
//  Created by Chia-Han Kuo on 29/10/2016.
//  Copyright © 2016 Chia-Han Kuo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KCHRoom : NSObject

@property (strong, nonatomic) NSString *uid;

@property (strong, nonatomic) NSString *name;

@property (strong, nonatomic) NSString *password;

@property (strong, nonatomic) NSMutableArray<NSString *> *participant;

- (instancetype)initWithUid:(NSString *)uid
                       name:(NSString *)name
                   password:(NSString *)password
                participant:(NSArray<NSString *> *)participant;

- (instancetype)initWithUid:(NSString *)uid info:(NSDictionary *)info;

- (NSDictionary *)dictionaryToSave;

+ (NSString *)roomPath:(NSString *)uid;

- (NSString *)roomPath;

- (NSString *)participantsPath:(NSString *)uid;
@end
