//
//  MagazineUndownloadedViewController_IPad.m
//  JingYingCar
//
//  Created by JiaMing Yan on 12-5-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MagazineUndownloadedViewController_IPad.h"
#import "MagazineReadingViewController_IPad.h"

@interface MagazineUndownloadedViewController_IPad ()

@end

@implementation MagazineUndownloadedViewController_IPad
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
    // If you create your views manually, you MUST override this method and use it to create your views.
    // If you use Interface Builder to create your views, then you must NOT override this method.
    [super loadView];
    arr_requests = [[NSMutableArray alloc] init];
    
    UIView *view_nav = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 768, 45)];
    view_nav.backgroundColor = [UIColor clearColor];
    [self.view addSubview:view_nav];
    
    UIImageView *imgView_navBK = [[UIImageView alloc] initWithFrame:view_nav.bounds];
    imgView_navBK.image = [UIImage imageNamed:@"magazineNav_ipad.png"];
    [view_nav addSubview:imgView_navBK];
    
    UIButton *btn_back = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_back.frame = CGRectMake(10, 7.5f, 55, 30);
    [btn_back setBackgroundImage:[UIImage imageNamed:@"back_ipad.png"] forState:UIControlStateNormal];
    //[btn_back setTitle:@" 返回" forState:UIControlStateNormal];
    [btn_back addTarget:self action:@selector(turnBack) forControlEvents:UIControlEventTouchUpInside];
    [btn_back setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn_back.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    btn_back.titleLabel.textAlignment = UITextAlignmentRight;
    [view_nav addSubview:btn_back];
    
    UIButton *btn_delete = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_delete.frame = CGRectMake(695, 7.5f, 60, 30);
    [btn_delete setBackgroundImage:[UIImage imageNamed:@"rectButton_ipad.png"] forState:UIControlStateNormal];
    [btn_delete setTitle:@"删除" forState:UIControlStateNormal];
    [btn_delete addTarget:self action:@selector(deleteMode) forControlEvents:UIControlEventTouchUpInside];
    [btn_delete setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn_delete.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    btn_delete.titleLabel.textAlignment = UITextAlignmentRight;
    [view_nav addSubview:btn_delete];
    
    UIView *view_content = [[UIView alloc] initWithFrame:CGRectMake(0, 45, 768, 960)];
    view_content.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"whiteBackground_ipad.png"]];
    [self.view addSubview:view_content];
    
    arr_magazineData = [[NSMutableArray alloc] init];
    arr_magazineList = [[NSMutableArray alloc] initWithArray:[[SqlManager sharedManager] getMagazineList]];
    NSLog(@"arr_magazineList:%@",arr_magazineList);
    
    tbl_magazineList = [[UITableView alloc] initWithFrame:view_content.bounds style:UITableViewStylePlain];
    tbl_magazineList.backgroundColor = [UIColor clearColor];
    tbl_magazineList.delegate = self;
    tbl_magazineList.dataSource =self;
    tbl_magazineList.separatorStyle = UITableViewCellSeparatorStyleNone;
    //tbl_magazineList.userInteractionEnabled = NO;
    [view_content addSubview:tbl_magazineList];
    
    isDeleteMode = NO;
    isScrolling = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark buttonFunction
-(void)turnBack
{
    [self cancelAllRequests];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)downloadMagazine:(UIButton *)sender
{
    //[sender setTitle:@"正在下载" forState:UIControlStateNormal];
    sender.enabled = NO;
    UITableViewCell *cell = (UITableViewCell *)sender.superview.superview.superview;
    NSIndexPath *indexpath = [tbl_magazineList indexPathForCell:cell];
    NSDictionary *dic_info = [arr_magazineList objectAtIndex:indexpath.row];
    
    UIImageView *imgView = (UIImageView *)[sender.superview viewWithTag:6];
    imgView.hidden = NO;
    
    NSString *str_url = [dic_info objectForKey:@"url"];
    NSLog(@"str_url:%@",[NSString stringWithFormat:@"%@/%@",BASIC_URL,str_url]);
    NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/%@",BASIC_URL,str_url]];
    //设置
	ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
	//设置ASIHTTPRequest代理
	request.delegate = self;
    //设置是是否支持断点下载
	[request setAllowResumeForFileDownloads:YES];
	//设置基本信息
    //NSString *httpBodyString = [self downloadMagazineRequestBody];
	//NSLog(@"request topiclist  httpBodyString :%@",httpBodyString);
	
    //NSData *postData = [httpBodyString dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *dic_userInfo = [[NSMutableDictionary alloc] init];
    [dic_userInfo setObject:@"downloadMagazine" forKey:@"operate"];
    [dic_userInfo setObject:[dic_info objectForKey:@"id"] forKey:@"id"];
    [dic_userInfo setObject:sender forKey:@"button"];
    [request setUserInfo:dic_userInfo];
    //[request setRequestMethod:@"POST"];
    //添加到ASINetworkQueue队列去下载
    AppDelegate_IPad *app = (AppDelegate_IPad *)[UIApplication sharedApplication].delegate;
	[app.netWorkQueue addOperation:request];
    [arr_requests addObject:request];
}

-(void)readMagazine:(UIButton *)sender
{
    UITableViewCell *cell = (UITableViewCell *)sender.superview.superview;
    NSIndexPath *indexpath = [tbl_magazineList indexPathForCell:cell];
    NSDictionary *dic_info = [arr_magazineList objectAtIndex:indexpath.row];
    MagazineReadingViewController_IPad *con_reading = [[MagazineReadingViewController_IPad alloc] init];
    NSString *str_id = [dic_info objectForKey:@"id"];
    con_reading.magazineID = str_id;
    [self.navigationController pushViewController:con_reading animated:YES];
}

-(void)deleteMode
{
    if (isDeleteMode == NO) {
        [tbl_magazineList setEditing:YES animated:YES];
    }
    else {
        [tbl_magazineList setEditing:NO animated:YES];
    }
    isDeleteMode = !isDeleteMode;
    [tbl_magazineList reloadData];
}

#pragma mark -
#pragma mark tableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [arr_magazineList count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 192;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        UIView *view_bk = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 768, 192)];
        view_bk.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"downloadTable_ipad.png"]];
        view_bk.tag = 0;
        [cell.contentView addSubview:view_bk];
        //cell.userInteractionEnabled = NO;
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(30, 25, 88, 132)];
        imgView.tag = 1;
        [view_bk addSubview:imgView];
        
        UILabel *lb_title = [[UILabel alloc] initWithFrame:CGRectMake(140, 15, 400, 45)];
        lb_title.textColor = [UIColor blackColor];
        lb_title.font = [UIFont systemFontOfSize:24];
        lb_title.backgroundColor = [UIColor clearColor];
        lb_title.tag = 2;
        [view_bk addSubview:lb_title];
        
        UILabel *lb_summary = [[UILabel alloc] initWithFrame:CGRectMake(140, 70, 400, 45)];
        lb_summary.lineBreakMode = UILineBreakModeMiddleTruncation;
        lb_summary.textColor = [UIColor blackColor];
        lb_summary.font = [UIFont systemFontOfSize:24];
        lb_summary.backgroundColor = [UIColor clearColor];
        lb_summary.tag = 3;
        [view_bk addSubview:lb_summary];
        
        UILabel *lb_update = [[UILabel alloc] initWithFrame:CGRectMake(140, 125, 400, 45)];
        lb_update.textColor = [UIColor blackColor];
        lb_update.font = [UIFont systemFontOfSize:24];
        lb_update.backgroundColor = [UIColor clearColor];
        lb_update.tag = 4;
        [view_bk addSubview:lb_update];
        
        UIButton *btn_download = [UIButton buttonWithType:UIButtonTypeCustom];
        btn_download.frame = CGRectMake(540, 60, 196, 56);
        [btn_download setBackgroundImage:[UIImage imageNamed:@"download_ipad.png"] forState:UIControlStateNormal];
        [btn_download setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        //[btn_download setTitle:@"下载" forState:UIControlStateNormal];
        btn_download.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        btn_download.tag = 5;
        [btn_download addTarget:self action:@selector(downloadMagazine:) forControlEvents:UIControlEventTouchUpInside];
        [view_bk addSubview:btn_download];
        
        UIButton *btn_read = [UIButton buttonWithType:UIButtonTypeCustom];
        btn_read.frame = CGRectMake(540, 60, 196, 56);
        [btn_read setBackgroundImage:[UIImage imageNamed:@"download.png"] forState:UIControlStateNormal];
        [btn_read setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn_read setTitle:@"阅读" forState:UIControlStateNormal];
        btn_read.titleLabel.font = [UIFont boldSystemFontOfSize:28];
        btn_read.tag = 6;
        [btn_read addTarget:self action:@selector(readMagazine:) forControlEvents:UIControlEventTouchUpInside];
        [view_bk addSubview:btn_read];
        
        UIImageView *imgView_progressBottom = [[UIImageView alloc] initWithFrame:CGRectMake(515, 140, 246, 8)];
        //imgView_progressBottom.image = [UIImage imageNamed:@"pgBottom_ipad.png"];
        [view_bk addSubview:imgView_progressBottom];
        imgView_progressBottom.hidden = YES; 
        imgView_progressBottom.tag = 7;
        
        UIImageView *imgView_progressTop = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 8)];
        imgView_progressTop.image = [UIImage imageNamed:@"pgTop_ipad.png"];
        [imgView_progressBottom addSubview:imgView_progressTop];
        imgView_progressTop.tag = 8;
        
        UILabel *lb_progress = [[UILabel alloc] initWithFrame:CGRectMake(515, 160, 246, 20)];
        lb_progress.font = [UIFont systemFontOfSize:18];
        lb_progress.textColor = [UIColor blackColor];
        lb_progress.textAlignment = UITextAlignmentCenter;
        lb_progress.tag = 9;
        lb_progress.backgroundColor = [UIColor clearColor];
        [view_bk addSubview:lb_progress];
        
        //        UIButton *btn_read = [UIButton buttonWithType:UIButtonTypeCustom];
        //        btn_read.frame = CGRectMake(230, 10, 80, 30);
        //        [btn_read setBackgroundImage:[UIImage imageNamed:@"download.png"] forState:UIControlStateNormal];
        //        [btn_read setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        //        [btn_read setTitle:@"阅读" forState:UIControlStateNormal];
        //        [btn_read addTarget:self action:@selector(readMagazine:) forControlEvents:UIControlEventTouchUpInside];
        //        btn_read.tag = 6;
        //        [view_bk addSubview:btn_read];
        
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if ([arr_magazineList count] >= indexPath.row +1) {
        UIView *view_bk = [cell.contentView viewWithTag:0];
        NSDictionary *dic_news = [arr_magazineList objectAtIndex:indexPath.row];
        NSString *str_coverAddress = [dic_news objectForKey:@"coverImgAddress"];
        UIImage *img_cover;
        if ([str_coverAddress length] > 0) {
            img_cover = [UIImage imageWithContentsOfFile:str_coverAddress];
        }
        else {
            img_cover = [UIImage imageNamed:@"magazinecover_ipad.png"];
        }
        UIImageView *imgView_cover = (UIImageView *)[view_bk viewWithTag:1];
        imgView_cover.image = img_cover;
        
        UILabel *lb_title = (UILabel *)[view_bk viewWithTag:2];
        lb_title.text = [dic_news objectForKey:@"title"];
        
        UILabel *lb_summary = (UILabel *)[view_bk viewWithTag:3];
        lb_summary.text = [dic_news objectForKey:@"summary"];
        
        UILabel *lb_createTime = (UILabel *)[view_bk viewWithTag:4];
        lb_createTime.text = [[dic_news objectForKey:@"createTime"] substringToIndex:10];
        
        NSString *str_address = [dic_news objectForKey:@"address"];
        UIButton *btn_download = (UIButton *)[view_bk viewWithTag:5];
        UIButton *btn_read = (UIButton *)[view_bk viewWithTag:6];
        //UIButton *btn_delete = (UIButton *)[view_bk viewWithTag:7];
        if (tableView.editing == YES) {
            //btn_download.hidden = YES;
            btn_read.hidden = YES;
        }
        else {
            if ([str_address length] > 0) {
                btn_download.hidden = YES;
                btn_read.hidden = NO;
                //btn_delete.hidden = NO;
            }
            else {
                btn_download.hidden = NO;
                btn_read.hidden = YES;
                //btn_delete.hidden = YES;
            }
        }
        
        NSString *str_id = [dic_news objectForKey:@"id"];
        for (int i = 0; i < [arr_magazineData count]; i++) {
            NSMutableDictionary *dic_magazineData = [arr_magazineData objectAtIndex:i];
            NSString *str_tempID = [dic_magazineData objectForKey:@"id"];
            if ([str_id isEqualToString:str_tempID]) {
                UIImageView *imgView_progressBottem = (UIImageView *)[view_bk viewWithTag:7];
                if (imgView_progressBottem.hidden == YES) {
                    imgView_progressBottem.hidden = NO;
                }
                
                UIImageView *imgView_top = (UIImageView *)[imgView_progressBottem viewWithTag:8];
                CGFloat percent = [[dic_magazineData objectForKey:@"percent"] floatValue];
//                CGImageRef imgRef = CGImageCreateWithImageInRect([[UIImage imageNamed:@"pgTop_ipad.png"] CGImage], CGRectMake(0, 0, 246*percent, 8));
//                UIImage *img = [UIImage imageWithCGImage:imgRef];
//                imgView_top.image = img;
                imgView_top.frame = CGRectMake(0, 0, 246*percent, 8);
                
                UILabel *lb_progress = (UILabel *)[view_bk viewWithTag:9];
                lb_progress.text = [NSString stringWithFormat:@"%.2f %%",percent *100];
                break;
            }
        }
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        NSDictionary *dic_magazine = [arr_magazineList objectAtIndex:indexPath.row];
        NSString *str_id = [dic_magazine objectForKey:@"id"];
        if ([[SqlManager sharedManager] deleteMagazine:str_id] == 0) {
            [arr_magazineList removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [delegate commitEditing:str_id];
        }
        //[self reload];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isDeleteMode == YES) {
        NSDictionary *dic_info = [arr_magazineList objectAtIndex:indexPath.row];
        NSString *str_address = [dic_info objectForKey:@"address"];
        if ([str_address length] > 0) {
            return UITableViewCellEditingStyleDelete;
        }
        else {
            return UITableViewCellAccessoryNone;
        }
    }
    else {
        return UITableViewCellAccessoryNone;
    }
    return UITableViewCellAccessoryNone;
}

#pragma mark - scrollviewDelegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == tbl_magazineList) {
        isScrolling = NO;
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == tbl_magazineList) {
        isScrolling = YES;
    }
}

#pragma mark -
#pragma mark ASIHttpRequestDelegate
//ASIHTTPRequestDelegate,下载之前获取信息的方法,主要获取下载内容的大小
- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders
{
    NSLog(@"%@",responseHeaders);
    NSDictionary *dic_userInfo = request.userInfo;
    NSString *str_id = [dic_userInfo objectForKey:@"id"];
    NSMutableDictionary *dic_magazineData = [[NSMutableDictionary alloc] init];
    [dic_magazineData setObject:str_id forKey:@"id"];
    NSString *str_dataLength = [responseHeaders objectForKey:@"Content-Length"];
    [dic_magazineData setObject:str_dataLength forKey:@"dataLength"];
    [arr_magazineData addObject:dic_magazineData];
}

-(void)request:(ASIHTTPRequest *)request didReceiveData:(NSData *)data
{
    NSDictionary *dic_userInfo = request.userInfo;
    NSString *str_id = [dic_userInfo objectForKey:@"id"];
    for (int i = 0; i < [arr_magazineData count]; i++) {
        NSMutableDictionary *dic_magazineData = [arr_magazineData objectAtIndex:i];
        NSString *str_tempID = [dic_magazineData objectForKey:@"id"];
        if ([str_id isEqualToString:str_tempID]) {
            NSMutableData *data_magazine = [dic_magazineData objectForKey:@"data"];
            if (data_magazine == nil) {
                data_magazine = [[NSMutableData alloc] init];
                [dic_magazineData setObject:data_magazine forKey:@"data"];
            }
            [data_magazine appendData:data];
            CGFloat dataLength = [[dic_magazineData objectForKey:@"dataLength"] floatValue];
            CGFloat percent = data_magazine.length/dataLength;
            NSLog(@"%d,%f,%f",data_magazine.length,dataLength,percent);
            [dic_magazineData setObject:[NSString stringWithFormat:@"%f",percent] forKey:@"percent"];
            if (isScrolling == NO) {
                [tbl_magazineList reloadData];
            }
            break;
        }
    }
}

//ASIHTTPRequestDelegate,下载完成时,执行的方法
- (void)requestFinished:(ASIHTTPRequest *)request {
    NSDictionary *dic_userInfo = request.userInfo;
    NSString *str_operate = [dic_userInfo objectForKey:@"operate"];
    //NSLog(@"str_operate:%@",str_operate);
    
    NSData *_data = request.responseData;
    NSString *responseString = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
    NSLog(@"responseString3:%@,%d",responseString,request.responseData.length);
    
    if ([str_operate isEqualToString:@"downloadMagazine"]) {
        UIButton *btn_temp = [dic_userInfo objectForKey:@"button"];
        //[btn_temp setTitle:@"已下载" forState:UIControlStateNormal];
        
        UIImageView *imgView_progressBottem = (UIImageView *)[btn_temp.superview.superview viewWithTag:7];
        UIImageView *imgView_top = (UIImageView *)[imgView_progressBottem viewWithTag:8];
        UILabel *lb_progress = (UILabel *)[btn_temp.superview.superview viewWithTag:9];
        imgView_top.frame = CGRectMake(0, 0, 160, 20);
        imgView_progressBottem.hidden = YES;
        lb_progress.text = @"";
        
        NSString *str_id = [dic_userInfo objectForKey:@"id"];
        for (int i = 0; i < [arr_magazineData count]; i++) {
            NSDictionary *dic_magazineData = [arr_magazineData objectAtIndex:i];
            NSString *str_tempID = [dic_magazineData objectForKey:@"id"];
            if ([str_id isEqualToString:str_tempID]) {
                NSData *data_magazine = [dic_magazineData objectForKey:@"data"];
                NSString *str_fileName = request.url.lastPathComponent;
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                NSString *str_address = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/Caches/Magazine/%@",str_fileName]];
                if ([[SqlManager sharedManager] saveDoc:data_magazine address:str_address] == YES) {
                    [[SqlManager sharedManager] saveMagezine:str_id magazineAddress:str_address];
                    [arr_magazineData removeObjectAtIndex:i];
                    [delegate commitEditing:str_id];
                }
            }
        }
        for (int i = 0; i < [arr_magazineList count]; i++) {
            NSDictionary *dic_magazineData = [arr_magazineList objectAtIndex:i];
            NSString *str_tempID = [dic_magazineData objectForKey:@"id"];
            if ([str_id isEqualToString:str_tempID]) {
                NSDictionary *dic_magazine = [[SqlManager sharedManager] getMagazineInfoWithID:str_id];
                [arr_magazineList replaceObjectAtIndex:i withObject:dic_magazine];
                if (isScrolling == NO) {
                    [tbl_magazineList reloadData];
                }
                break;
            }
        }
    }
}


//ASIHTTPRequestDelegate,下载失败
- (void)requestFailed:(ASIHTTPRequest *)request {
    //    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" 
    //                                                        message:@"下载失败，请检查网络状况"
    //                                                       delegate:self 
    //                                              cancelButtonTitle:@"确定"
    //                                              otherButtonTitles:nil];
    //    
    //    [alertView show];
}

-(void)cancelAllRequests
{
    for (int i = 0; i < [arr_requests count]; i++) {
        ASIHTTPRequest *request = [arr_requests objectAtIndex:i];
        [request cancel];
    }
    [arr_requests removeAllObjects];
}

@end

