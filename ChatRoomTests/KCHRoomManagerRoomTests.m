//
//  KCHRoomManagerRoomTests.m
//  ChatRoom
//
//  Created by Chia-Han Kuo on 30/10/2016.
//  Copyright © 2016 Chia-Han Kuo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "KCHRoomsManager.h"
#define ALWAYS_EXIST_1_EMAIL @"always1@somewhere.com"
#define ALWAYS_EXIST_1_PASSWORD @"12345678"
#define ALWAYS_EXIST_2_EMAIL @"always2@somewhere.com"
#define ALWAYS_EXIST_2_PASSWORD @"12345678"

@interface KCHRoomManagerRoomTests : XCTestCase

@end

@implementation KCHRoomManagerRoomTests

- (void)setUp {
    [super setUp];
    [self loginOrSignUpUser:ALWAYS_EXIST_1_EMAIL password:ALWAYS_EXIST_1_PASSWORD];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [[KCHRoomsManager sharedManager] logout];
    [super tearDown];
}

- (void)testCreateLeave {
    NSString *roomId = [self createRoomWithPassword:nil shouldSuccess:YES];
    
    [self logout];
    
    [self loginWithEmail:ALWAYS_EXIST_1_EMAIL password:ALWAYS_EXIST_1_PASSWORD];
    
    [self leaveRoom:roomId];
    
    [self logout];
    
    [self loginWithEmail:ALWAYS_EXIST_1_EMAIL password:ALWAYS_EXIST_1_PASSWORD];
    
    XCTAssertNil([self findRoomInChatingRooms:roomId], @"Room is still in the list!");
}

- (void)testCreateJoinLeave {
    NSString *roomId = [self createRoomWithPassword:nil shouldSuccess:YES];

    [self logout];

    [self loginOrSignUpUser:ALWAYS_EXIST_2_EMAIL password:ALWAYS_EXIST_2_PASSWORD];

    [self join:roomId withPassword:nil shouldSuccess:YES];

    [self logout];

    [self loginWithEmail:ALWAYS_EXIST_1_EMAIL password:ALWAYS_EXIST_1_PASSWORD];

    [self leaveRoom:roomId];

    [self logout];

    [self loginWithEmail:ALWAYS_EXIST_2_EMAIL password:ALWAYS_EXIST_2_PASSWORD];

    [self leaveRoom:roomId];

    XCTAssertNil([self findRoomInJoinableRooms:roomId], @"Room is still in the list!");

    [self logout];

    [self loginWithEmail:ALWAYS_EXIST_2_EMAIL password:ALWAYS_EXIST_2_PASSWORD];

    XCTAssertNil([self findRoomInJoinableRooms:roomId], @"Room is still in the list!");
}

- (void)testQuotaLimitation {
    for (KCHRoom *room in [KCHRoomsManager sharedManager].chatingRooms ) {
        [self leaveRoom:room.uid];
    }
    NSMutableArray<NSString *> *roomIds = [NSMutableArray array];
    [roomIds addObject:[self createRoomWithPassword:nil shouldSuccess:YES]];
    [roomIds addObject:[self createRoomWithPassword:nil shouldSuccess:YES]];
    [roomIds addObject:[self createRoomWithPassword:nil shouldSuccess:YES]];
    [roomIds addObject:[self createRoomWithPassword:nil shouldSuccess:YES]];
    [roomIds addObject:[self createRoomWithPassword:nil shouldSuccess:YES]];
    [self createRoomWithPassword:nil shouldSuccess:NO];

    [self logout];
    [self loginWithEmail:ALWAYS_EXIST_1_EMAIL password:ALWAYS_EXIST_1_PASSWORD];
    [self createRoomWithPassword:nil shouldSuccess:NO];
    [self leaveRoom:roomIds.lastObject];
    [roomIds removeLastObject];
    [roomIds addObject:[self createRoomWithPassword:nil shouldSuccess:YES]];
    [self createRoomWithPassword:nil shouldSuccess:NO];
    [self leaveRoom:roomIds.lastObject];
    [roomIds removeLastObject];
    [self leaveRoom:roomIds.lastObject];
    [roomIds removeLastObject];
    [self leaveRoom:roomIds.lastObject];
    [roomIds removeLastObject];
    [self leaveRoom:roomIds.lastObject];
    [roomIds removeLastObject];
    [self leaveRoom:roomIds.lastObject];
    [roomIds removeLastObject];
}

- (void)testPassword {
    NSString *roomId = [self createRoomWithPassword:@"Correct PW" shouldSuccess:YES];

    [self logout];

    [self loginOrSignUpUser:ALWAYS_EXIST_2_EMAIL password:ALWAYS_EXIST_2_PASSWORD];

    [self join:roomId withPassword:nil shouldSuccess:NO];
    [self join:roomId withPassword:@"Wrong PW" shouldSuccess:NO];
    [self join:roomId withPassword:@"Correct PW" shouldSuccess:YES];

    [self logout];

    [self loginWithEmail:ALWAYS_EXIST_1_EMAIL password:ALWAYS_EXIST_1_PASSWORD];

    [self leaveRoom:roomId];
}

- (void)loginOrSignUpUser:(NSString *)email password:(NSString *)password {
    XCTestExpectation *expect = [self expectationWithDescription:@"Account should exist"];
    [[KCHRoomsManager sharedManager] loginWithEmail:email password:password completion:^(NSError *error) {
        if (error) {
            XCTAssertEqual(17011, error.code, @"Login failed:%@", error.localizedDescription); // FIRAuthErrorCodeUserNotFound = 17011
            [[KCHRoomsManager sharedManager] signUpWithEmail:email password:password completion:^(NSError *error) {
                XCTAssertNil(error, @"Sign up failed:%@", error.localizedDescription);
                [expect fulfill];
            }];
        } else {
            [expect fulfill];
        }
    }];
    [self waitForExpectationsWithTimeout:4 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"Wait failed:%@", error.localizedDescription);
    }];
}

- (void)loginWithEmail:(NSString *)email password:(NSString *)password {
    XCTestExpectation *expect = [self expectationWithDescription:@"Log in"];
    [[KCHRoomsManager sharedManager] loginWithEmail:email password:password completion:^(NSError *error) {
        XCTAssertNil(error, @"Login failed:%@", error.localizedDescription);
        [expect fulfill];
    }];
    [self waitForExpectationsWithTimeout:3 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"Wait failed:%@", error.localizedDescription);
    }];

}

- (void)logout {
    [[KCHRoomsManager sharedManager] logout];
    XCTAssertTrue([KCHRoomsManager sharedManager].chatingRooms.count == 0, @"Rooms should be empty!");
    
}

- (NSString *)createRoomWithPassword:(NSString *)password shouldSuccess:(BOOL)shouldSuccess {
    XCTestExpectation *expect = [self expectationWithDescription:@"Create room"];
    __block NSString *_roomId;
    [[KCHRoomsManager sharedManager] creatRoom:@"room name" password:password completion:^(KCHRoom *room, NSError *error) {
        if (shouldSuccess) {
            XCTAssertNil(error, @"Create failed:%@", error.localizedDescription);
            XCTAssertNotNil(room, @"Null room!");
            _roomId = room.uid;
        } else {
            XCTAssertNotNil(error, @"Create shouldn't success");
            XCTAssertNil(room, @"Non-Null room!");
        }
        [expect fulfill];
    }];
    [self waitForExpectationsWithTimeout:3 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"Wait failed:%@", error);
    }];
    if (shouldSuccess) {
        XCTAssertNotNil([self findRoomInChatingRooms:_roomId], @"Room is not in the list!");
    }
    return _roomId;
}

- (KCHRoom *)findRoomInChatingRooms:(NSString *)roomId {
    KCHRoom *room = nil;
    for (KCHRoom *r in [KCHRoomsManager sharedManager].chatingRooms) {
        if ([roomId isEqualToString:r.uid]) {
            room = r;
            break;
        }
    }
    return room;
}

- (KCHRoom *)findRoomInJoinableRooms:(NSString *)roomId {
    __block KCHRoom *room = nil;
    XCTestExpectation *expect = [self expectationWithDescription:@"The room should be in the joinable rooms list"];
    [[KCHRoomsManager sharedManager] queryJoinableRooms:^(NSArray<KCHRoom *> *joinableRooms) {
        for (KCHRoom *r in joinableRooms) {
            if ([roomId isEqualToString:r.uid]) {
                room = r;
                break;
            }
        }
        [expect fulfill];
    }];
    [self waitForExpectationsWithTimeout:3 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"Wait failed:%@", error.localizedDescription);
    }];
    return room;
}

- (void)leaveRoom:(NSString *)roomId {
    KCHRoom *room = [self findRoomInChatingRooms:roomId];
    XCTAssertNotNil(room, @"Room is not in the list");
    
    XCTestExpectation *expect = [self expectationWithDescription:@"Leave room"];
    [[KCHRoomsManager sharedManager] leaveRoom:room completion:^(NSError *error) {
        XCTAssertNil(error, @"Leave failed:%@", error.localizedDescription);
        [expect fulfill];
    }];
    [self waitForExpectationsWithTimeout:3 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"Wait failed:%@", error);
    }];
    ;
    XCTAssertNil([self findRoomInChatingRooms:roomId], @"Room is still in the list!");
}

- (void)join:(NSString *)roomId withPassword:(NSString *)password shouldSuccess:(BOOL)shouldSuccess{
    KCHRoom *room = [self findRoomInJoinableRooms:roomId];
    XCTAssertNotNil(room, @"Room is not in the list");
    XCTestExpectation *expect = [self expectationWithDescription:@"Join room"];
    [[KCHRoomsManager sharedManager] joinRoom:room password:password completion:^(NSError *error) {
        if (shouldSuccess) {
            XCTAssertNil(error, @"Join failed:%@", error.localizedDescription);
        } else {
            XCTAssertNotNil(error, @"Join shouldn't success");
        }
        [expect fulfill];
    }];
    [self waitForExpectationsWithTimeout:3 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"Wait failed:%@", error);
    }];
    
    if (shouldSuccess) {
        XCTAssertNotNil([self findRoomInChatingRooms:roomId], @"Room is not in the list!");
    }
}
@end
