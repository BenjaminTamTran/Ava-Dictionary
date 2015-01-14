//
//  MNViewDetailViewController.m
//  Mana Framework
//
//  Created by Toan Le on 04/03/2013.
//  Copyright (c) 2013 Song Vang. All rights reserved.
//

#import "MNViewDetailViewController.h"

@interface MNViewDetailViewController ()

@end

@implementation MNViewDetailViewController
@synthesize array;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withArrayURL:(NSArray *)_array withIndex:(int)_index
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        self.array = [[NSArray alloc]init];
        self.array = _array;
        indexShow = _index;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	self.title = @"View Detail Framework";
	self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
	
	self.view.backgroundColor = [UIColor blackColor];
	self.paginatorView.pageGapWidth = 0.0f;
    [self.paginatorView reloadDataRemovingCurrentPage:YES];
    [self.paginatorView setCurrentPageIndex:indexShow animated:YES];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO];
}


#pragma mark - TKPaginatorViewDataSource

- (NSInteger)numberOfPagesForPaginatorView:(TKPaginatorView *)paginatorView
{
    if(self.array.count > 0)
    {
        return self.array.count;
    }
    else
    {
        return 0;
    }
}

- (TKPageView *)paginatorView:(TKPaginatorView *)paginatorView viewForPageAtIndex:(NSInteger)pageIndex {
	
    static NSString *identifier = @"identifier";
	
	MNPageView *view = (MNPageView *)[paginatorView dequeueReusablePageWithIdentifier:identifier];
    
	if (view == nil)
    {
		view = [[MNPageView alloc] initWithReuseIdentifier:identifier];
	}
    
    NSLog(@"PageIndex:%d",pageIndex);
    NSLog(@"ArrayCount:%d",self.array.count);
    
    NSString *url = [self.array objectAtIndex:pageIndex];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [view.webView  loadRequest:request];

	return view;
}
-(void)paginatorView:(TKPaginatorView *)paginatorView
     willDisplayView:(UIView *)view
             atIndex:(NSInteger)pageIndex
{
    NSLog(@"will display view at index: %i", pageIndex + 1);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
