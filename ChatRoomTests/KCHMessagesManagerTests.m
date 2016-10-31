//
//  KCHMessagesManagerTests.m
//  ChatRoom
//
//  Created by Chia-Han Kuo on 01/11/2016.
//  Copyright © 2016 Chia-Han Kuo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "KCHRoomsManager.h"
#import "KCHMessagesManager.h"
#define ALWAYS_EXIST_1_EMAIL @"always1@somewhere.com"
#define ALWAYS_EXIST_1_PASSWORD @"12345678"

@interface KCHMessagesManagerTests : XCTestCase {
    NSString *_roomId;
}

@end

@implementation KCHMessagesManagerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [self loginOrSignUpUser:ALWAYS_EXIST_1_EMAIL password:ALWAYS_EXIST_1_PASSWORD];
    _roomId = [self createRoomWithPassword:nil shouldSuccess:YES];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [self leaveRoom:_roomId];
    [self logout];
    [super tearDown];
}

- (void)testSimpleSend {
    [self sendText:@"123"];
}

- (void)testLimitation {
    for (NSInteger i = 0; i < 104; i++) {
        [self sendText:[NSString stringWithFormat:@"%ld", i]];
    }
}

- (void)testObserve {
    __block XCTestExpectation *expect = [self expectationWithDescription:@"should wait for first observe"];
    NSMutableArray<NSString *> *sentMessages = [NSMutableArray array];
    [[KCHMessagesManager sharedManager] observeMessagesOfRoom:_roomId withCompletion:^(NSArray<KCHMessage *> *messages) {
        BOOL allFound = YES;
        NSMutableArray<KCHMessage *> *mutableMessages = messages.mutableCopy;
        for (NSString *s in sentMessages) {
            BOOL found = NO;
            for (NSInteger i = (mutableMessages.count - 1); i >= 0; i--) {
                KCHMessage *m = mutableMessages[i];
                if ([m.content isEqualToString:s]) {
                    found = YES;
                    [mutableMessages removeObjectAtIndex:i];
                }
            }
            XCTAssertTrue(found, @"Can't find \"%@\"", s);
            allFound &= found;
        }
        if (allFound) {
            [expect fulfill];
        }
    }];
    [self waitForExpectationsWithTimeout:4 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"Wait failed:%@", error);
    }];

    expect = [self expectationWithDescription:@"should wait observe"];
    NSString *s = @"123";
    [sentMessages addObject:s];
    [self sendTextWithoutWaiting:s];
    [self waitForExpectationsWithTimeout:4 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"Wait failed:%@", error);
    }];

    [[KCHMessagesManager sharedManager] stopObserving:_roomId];
}

- (void)testObserveWithLimitation {
    __block XCTestExpectation *expect = [self expectationWithDescription:@"should wait for first observe"];
    NSMutableArray<NSString *> *sentMessages = [NSMutableArray array];
    [[KCHMessagesManager sharedManager] observeMessagesOfRoom:_roomId withCompletion:^(NSArray<KCHMessage *> *messages) {
        BOOL allFound = YES;
        NSMutableArray<KCHMessage *> *mutableMessages = messages.mutableCopy;
        for (NSString *s in sentMessages) {
            BOOL found = NO;
            for (NSInteger i = (mutableMessages.count - 1); i >= 0; i--) {
                KCHMessage *m = mutableMessages[i];
                if ([m.content isEqualToString:s]) {
                    found = YES;
                    [mutableMessages removeObjectAtIndex:i];
                }
            }
            XCTAssertTrue(found, @"Can't find \"%@\"", s);
            allFound &= found;
        }
        if (allFound) {
            [expect fulfill];
            expect = nil;
        }
    }];
    [self waitForExpectationsWithTimeout:4 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"Wait failed:%@", error);
    }];

    for (NSInteger i = 0; i < 105; i++) {
        expect = [self expectationWithDescription:[NSString stringWithFormat:@"should wait observe %d", i]];
        NSString *s = [NSString stringWithFormat:@"%ld", i];
        [sentMessages addObject:s];
        if (sentMessages.count > 100) {
            [sentMessages removeObjectsInRange:NSMakeRange(0, sentMessages.count - 100)];
        }
        [self sendTextWithoutWaiting:s];
        [self waitForExpectationsWithTimeout:4 handler:^(NSError * _Nullable error) {
            XCTAssertNil(error, @"Wait failed:%@", error);
        }];
    }

    [[KCHMessagesManager sharedManager] stopObserving:_roomId];
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

- (NSString *)createRoomWithPassword:(NSString *)password shouldSuccess:(BOOL)shouldSuccess {
    XCTestExpectation *expect = [self expectationWithDescription:@"Create room"];
    __block NSString *roomId;
    [[KCHRoomsManager sharedManager] creatRoom:@"room name" password:password completion:^(KCHRoom *room, NSError *error) {
        if (shouldSuccess) {
            XCTAssertNil(error, @"Create failed:%@", error.localizedDescription);
            XCTAssertNotNil(room, @"Null room!");
            roomId = room.uid;
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
        XCTAssertNotNil([self findRoomInChatingRooms:roomId], @"Room is not in the list!");
    }
    return roomId;
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
    XCTAssertNil([self findRoomInChatingRooms:roomId], @"Room is still in the list!");
}

- (void)logout {
    [[KCHRoomsManager sharedManager] logout];
    XCTAssertTrue([KCHRoomsManager sharedManager].chatingRooms.count == 0, @"Rooms should be empty!");
}

- (void)sendText:(NSString *)content {
    [self sendTextWithoutWaiting:content];
    [self waitForExpectationsWithTimeout:3 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"Wait failed:%@", error);
    }];
}

- (void)sendTextWithoutWaiting:(NSString *)content {
    XCTestExpectation *expect = [self expectationWithDescription:@"Send should success"];
    [[KCHMessagesManager sharedManager] sendMessageToRoom:_roomId
                                                 WithType:@"text"
                                                  content:content
                                           withCompletion:^(NSError *error) {
                                               XCTAssertNil(error, @"send %@ failed:%@", content, error.localizedDescription);
                                               [expect fulfill];
                                           }];
}

@end
