//
//  KCHViews.m
//  ChatRoom
//
//  Created by Chia-Han Kuo on 28/10/2016.
//  Copyright © 2016 Chia-Han Kuo. All rights reserved.
//

#import "KCHViews.h"

@implementation KCHViews

+ (void)showLoadingInView:(UIView *)view
{
    if ([view viewWithTag:KCH_LOADING_TAG] != nil)
        return;
    UIView *loadingView = [[UIView alloc] initWithFrame:view.bounds];
    loadingView.tag = KCH_LOADING_TAG;
    loadingView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.center = loadingView.center;
    [indicator startAnimating];
    [loadingView addSubview:indicator];
    [view addSubview:loadingView];
}

+ (void)hideLoadingInView:(UIView *)view
{
    UIView *loadingView = [view viewWithTag:KCH_LOADING_TAG];
    if (loadingView)
        [loadingView removeFromSuperview];
}

+ (void)showAlertInView:(UIViewController *)vc
                  title:(NSString *)title
                message:(NSString *)message
                handler:(void (^ __nullable)(UIAlertAction *action))handler {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:title
                                          message:message
                                          preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:handler];
    [alertController addAction:okAction];
    [vc presentViewController:alertController animated:YES completion:nil];
}

@end
