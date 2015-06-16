//
//  ViewController.h
//  TuneSearch
//
//  Created by Jack Borthwick on 6/15/15.
//  Copyright (c) 2015 Jack Borthwick. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"
#import <Social/Social.h>

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> 

@property (nonatomic, strong) NSArray *itemArray;

@end

