//
//  KCHSingleton.h
//  ChatRoom
//
//  Created by Chia-Han Kuo on 25/10/2016.
//  Copyright © 2016 Chia-Han Kuo. All rights reserved.
//

#ifndef KCHSingleton_h
#define KCHSingleton_h

#define DECLARE_SINGLETON_FOR_CLASS(classname) \
\
+ (classname *)shared##classname; \

#define IMPLEMENT_SINGLETON_FOR_CLASS(classname) \
\
+ (classname *)shared##classname \
{ \
static classname *shared##classname = nil; \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
shared##classname = [[classname alloc] init]; \
}); \
\
return shared##classname; \
} \

#define DECLARE_SINGLETON_FOR_MANAGER_CLASS(classname) \
\
+ (classname *)sharedManager; \

#define IMPLEMENT_SINGLETON_FOR_MANAGER_CLASS(classname) \
\
+ (classname *)sharedManager \
{ \
static classname *sharedManager = nil; \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
sharedManager = [[classname alloc] init]; \
}); \
return sharedManager; \
} \

#endif /* KCHSingleton_h */
