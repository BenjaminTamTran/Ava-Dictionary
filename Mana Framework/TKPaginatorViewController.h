//
//  TKPaginatorViewController.h
//  TestSwipeWebView
//
//  Created by Toan Le on 27/12/2012.
//  Copyright (c) 2012 Toan Le. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TKPaginatorView.h"
#import "GAI.h"

@interface TKPaginatorViewController : GAITrackedViewController  <TKPaginatorViewDataSource, TKPaginatorViewDelegate>

@property (nonatomic, strong, readonly) TKPaginatorView *paginatorView;

@end

