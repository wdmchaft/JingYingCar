//
//  SearchViewController.h
//  JingYingCar
//
//  Created by JiaMing Yan on 12-4-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface SearchViewController : UIViewController<UISearchBarDelegate,UISearchDisplayDelegate,UITableViewDelegate,UITableViewDataSource>
{
    UISearchBar *schBar;
    
    UITableView *tbl_result;
    
    NSMutableArray *arr_result;
    
    UIActivityIndicatorView *indViewLarge;
    
    NSMutableArray *arr_requests;
}

@end
