//
//  KCHRoomsManager.h
//  ChatRoom
//
//  Created by Chia-Han Kuo on 29/10/2016.
//  Copyright © 2016 Chia-Han Kuo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KCHRoom.h"

@interface KCHRoomsManager : NSObject

DECLARE_SINGLETON_FOR_MANAGER_CLASS(KCHRoomsManager)

- (void)signUpWithEmail:(NSString *)email
               password:(NSString *)password
             completion:(void(^)(NSError *error))completion;

- (void)loginWithEmail:(NSString *)email
               password:(NSString *)password
             completion:(void(^)(NSError *error))completion;

- (void)changePasswor:(NSString *)newPassword
           completion:(void(^)(NSError *error))completion;

- (void)creatRoom:(NSString *)name
         password:(NSString *)password
       completion:(void(^)(KCHRoom *room, NSError *error))completion;

- (void)joinRoom:(KCHRoom *)room
        password:(NSString *)password
      completion:(void(^)(NSError *error))completion;

- (void)leaveRoom:(KCHRoom *)room
       completion:(void(^)(NSError *error))completion;

- (void)logout;

- (void)deleteAccount:(void(^)(NSError *error))completion;

@property (strong, nonatomic, readonly) NSArray<KCHRoom *> *chatingRooms;

- (void)queryJoinableRooms:(void(^)(NSArray<KCHRoom *> *joinableRooms))completion;

@end
