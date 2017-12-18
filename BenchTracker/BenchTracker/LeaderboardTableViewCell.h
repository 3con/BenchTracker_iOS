//
//  LeaderboardTableViewCell.h
//  BenchTracker
//
//  Created by Chappy Asel on 12/16/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeaderboardTableViewCell : UITableViewCell

@property (nonatomic) NSInteger rank;
@property (nonatomic) BOOL isSelf;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *statLabel;

@end
