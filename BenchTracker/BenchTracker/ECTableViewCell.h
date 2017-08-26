//
//  ECTableViewCell.h
//  BenchTracker
//
//  Created by Chappy Asel on 8/1/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ECTableViewCell : UITableViewCell

@property (nonatomic) NSInteger selectedSection;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

- (void)loadWithWeight:(NSInteger)weight length:(NSInteger)length;

@end
