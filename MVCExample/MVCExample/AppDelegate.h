//
//  AppDelegate.h
//  MVCExample
//
//  Created by 常立山 on 2017/11/25.
//  Copyright © 2017年 常立山. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

