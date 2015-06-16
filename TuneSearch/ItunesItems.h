//
//  ItunesItems.h
//  TuneSearch
//
//  Created by Jack Borthwick on 6/16/15.
//  Copyright (c) 2015 Jack Borthwick. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ItunesItems : NSObject

@property (nonatomic, strong) NSString          *itemName;
@property (nonatomic, strong) NSString          *itemImageURL;
@property (nonatomic, strong) NSDate            *dateUpdated;
@property (nonatomic, strong) NSNumber          *itemID;
@property (nonatomic, strong) NSNumber          *otherItemID;

@end
