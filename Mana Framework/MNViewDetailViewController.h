//
//  MNViewDetailViewController.h
//  Mana Framework
//
//  Created by Toan Le on 04/03/2013.
//  Copyright (c) 2013 Song Vang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TKPaginatorViewController.h"
#import "MNPageView.h"

@interface MNViewDetailViewController : TKPaginatorViewController
{
    int indexShow;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withArrayURL:(NSArray *)_array withIndex:(int)_index;
@property (nonatomic, strong) NSArray *array;

@end
