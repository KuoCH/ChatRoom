//
//  KCHViews.h
//  ChatRoom
//
//  Created by Chia-Han Kuo on 28/10/2016.
//  Copyright © 2016 Chia-Han Kuo. All rights reserved.
//

#import <Foundation/Foundation.h>

#define KCH_LOADING_TAG 3618

@interface KCHViews : NSObject

+ (void)showLoadingInView:(UIView *)view;
+ (void)hideLoadingInView:(UIView *)view;

+ (void)showAlertInView:(UIViewController *)vc
                  title:(NSString *)title
                message:(NSString *)message
                handler:(void (^ )(UIAlertAction *action))handler;

@end
