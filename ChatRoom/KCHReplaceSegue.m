//
//  KCHReplaceSegue.m
//  ChatRoom
//
//  Replace the source ViewController with destination ViewController
//  Reference: http://stackoverflow.com/a/26478478
//
//  Created by Chia-Han Kuo on 23/10/2016.
//  Copyright © 2016 Chia-Han Kuo. All rights reserved.
//

#import "KCHReplaceSegue.h"

@implementation KCHReplaceSegue

- (void)perform {
    // Grab Variables for readability
    UIViewController *sourceViewController = (UIViewController*)[self sourceViewController];
    UIViewController *destinationController = (UIViewController*)[self destinationViewController];
    UINavigationController *navigationController = sourceViewController.navigationController;
    
    // Get a changeable copy of the stack
    NSMutableArray *controllerStack = [NSMutableArray arrayWithArray:navigationController.viewControllers];
    // Replace the source controller with the destination controller, wherever the source may be
    [controllerStack replaceObjectAtIndex:[controllerStack indexOfObject:sourceViewController] withObject:destinationController];
    
    // Assign the updated stack with animation
    [navigationController setViewControllers:controllerStack animated:YES];
}

@end
