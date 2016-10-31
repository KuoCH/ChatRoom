//
//  KCHRoomManagerAccountTests.m
//  ChatRoom
//
//  Created by Chia-Han Kuo on 31/10/2016.
//  Copyright © 2016 Chia-Han Kuo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "KCHRoomsManager.h"
#define SIGNUP_EMAIL @"signup@somewhere.com"
#define SIGNUP_PASSWORD @"12345678"

@interface KCHRoomManagerAccountTests : XCTestCase

@end

@implementation KCHRoomManagerAccountTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

// Sign Up, Logout, Sign Up failed, Login, Delete Account, Login failed
- (void)testAccount {
    XCTestExpectation *expect = [self expectationWithDescription:@"Sign-up should success"];
    [[KCHRoomsManager sharedManager] signUpWithEmail:SIGNUP_EMAIL password:SIGNUP_PASSWORD completion:^(NSError *error) {
        XCTAssertNil(error, @"Sign up failed with error:%@", error.localizedDescription);
        [expect fulfill];
    }];
    [self waitForExpectationsWithTimeout:3 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"waitForExpectationsWithTimeout failed");
    }];
    
    [[KCHRoomsManager sharedManager] logout];
    
    expect = [self expectationWithDescription:@"Sign-up should fail"];
    [[KCHRoomsManager sharedManager] signUpWithEmail:SIGNUP_EMAIL password:SIGNUP_PASSWORD completion:^(NSError *error) {
        XCTAssertNotNil(error, @"Sign up didn't fail");
        [expect fulfill];
    }];
    [self waitForExpectationsWithTimeout:3 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"waitForExpectationsWithTimeout failed");
    }];
    
    expect = [self expectationWithDescription:@"login should success"];
    [[KCHRoomsManager sharedManager] loginWithEmail:SIGNUP_EMAIL password:SIGNUP_PASSWORD completion:^(NSError *error) {
        XCTAssertNil(error, @"Log in failed with error:%@", error.localizedDescription);
        [expect fulfill];
    }];
    [self waitForExpectationsWithTimeout:3 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"waitForExpectationsWithTimeout failed");
    }];
    
    expect = [self expectationWithDescription:@"delete should success"];
    [[KCHRoomsManager sharedManager] deleteAccount:^(NSError *error) {
        XCTAssertNil(error, @"Delete account failed with error:%@", error.localizedDescription);
        [expect fulfill];
    }];
    [self waitForExpectationsWithTimeout:3 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"waitForExpectationsWithTimeout failed");
    }];
    
    expect = [self expectationWithDescription:@"Log-in should fail"];
    [[KCHRoomsManager sharedManager] loginWithEmail:SIGNUP_EMAIL password:SIGNUP_PASSWORD completion:^(NSError *error) {
        XCTAssertNotNil(error, @"Log in didn't fail");
        [expect fulfill];
    }];
    [self waitForExpectationsWithTimeout:3 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"waitForExpectationsWithTimeout failed");
    }];
    
}

@end
