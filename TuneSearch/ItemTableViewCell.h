//
//  ItemTableViewCell.h
//  TuneSearch
//
//  Created by Jack Borthwick on 6/15/15.
//  Copyright (c) 2015 Jack Borthwick. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ItemTableViewCell : UITableViewCell

@property (nonatomic,strong)IBOutlet UILabel *itemNameLabel;
@property (nonatomic, strong)IBOutlet UILabel *itemKind;
@property (nonatomic,strong)IBOutlet UILabel *genreLabel;
@property (nonatomic, strong)IBOutlet UIImageView *itemImageView;
@end
