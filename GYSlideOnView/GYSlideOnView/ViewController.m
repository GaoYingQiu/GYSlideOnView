//
//  ViewController.m
//  GYSlideOnView
//
//  Created by qiugaoying on 2019/2/18.
//  Copyright © 2019年 qiugaoying. All rights reserved.
//

#import "ViewController.h"
#import <Masonry.h>
#import "GYShadeView.h"

#define SCREEN_H  [UIScreen mainScreen].bounds.size.height
#define LStatusBarHeight                [[UIApplication sharedApplication] statusBarFrame].size.height
#define LNavBarHeight                   44.0

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource,UIGestureRecognizerDelegate>
{
    CGPoint startSpanPoint;
    
    NSInteger pointB1_Y;//记录上一次拖动的 0 默认值 1 往上， -1往下；
    BOOL blChange ; //NO 默认一个方向 ，YES 为改变过方向：来回拖动的情况；
    BOOL bBottom_Top_Flag;
}

@property(nonatomic,assign) CGFloat listViewMinTop;
@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,assign) CGFloat mapViewHeight;
@property(nonatomic,strong) NSMutableArray *datas;
@property(nonatomic,strong) GYShadeView *styleView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"GYSlideOnView";
    _datas = [[NSMutableArray alloc]init];
    
    //高度配置；
    self.mapViewHeight = self.view.frame.size.height * 0.65;
    self.listViewMinTop = 95;
  
    //遮罩
    self.styleView = [[GYShadeView alloc] initWithFrame:self.view.bounds];
    self.styleView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.styleView.opaque = NO;
    self.styleView.tag = 8888;
    [self.view addSubview:self.styleView];
    self.styleView.alpha = 0;
    
    //列表；
    [self addActivityTableView];
    
    self.view.backgroundColor = [UIColor colorWithRed:66/255.f green:185/255.f blue:1 alpha:1];
    UIPanGestureRecognizer *panpress = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panScroll:)];
    panpress.delegate = self;
    [self.view addGestureRecognizer:panpress];
}


#pragma mark - UITableViewDelegate & UITableViewDataSource
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    cell.textLabel.text = [NSString stringWithFormat:@"第%ld行数据",indexPath.row+1];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 20;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    UILabel *msgLabel  =[[UILabel alloc]init];
    msgLabel.font = [UIFont systemFontOfSize:15];
    msgLabel.textColor = [UIColor whiteColor];
    msgLabel.text = @"^试试拖动列表，支持来回拖动^";
    msgLabel.textAlignment = NSTextAlignmentCenter;
    
    headerView.backgroundColor = [UIColor colorWithRed:231/255.0f green:60/255.0f blue:0 alpha:1];
    
    [headerView addSubview:msgLabel];
    msgLabel.frame = CGRectMake(10, 0, self.view.frame.size.width-20, 30);
    return headerView;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0f;
}


- (void)addActivityTableView{
    
    _tableView                              = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.separatorInset               = UIEdgeInsetsMake(0, 0, 0, 0);
    _tableView.estimatedRowHeight           = 0;
    _tableView.estimatedSectionHeaderHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;
    _tableView.backgroundColor              = [UIColor clearColor];
    _tableView.scrollsToTop                 = YES;
    _tableView.separatorColor               = [UIColor lightGrayColor];
    _tableView.tableFooterView              = [[UIView alloc] init];
    _tableView.delegate                     = self;
    _tableView.dataSource                   = self;
    _tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _tableView.rowHeight = 44;
    [self.view addSubview:_tableView];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.layer.cornerRadius = 5;
    self.tableView.layer.masksToBounds = YES;
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mapViewHeight);
        make.left.mas_equalTo(7);
        make.right.mas_equalTo(-7); //考虑到手势会触摸在屏幕
        make.height.equalTo(@(SCREEN_H-self.listViewMinTop-(LStatusBarHeight+44)));
    }];
    self.tableView.tag = 1000;
}

#pragma mark - 允许多手势响应
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    if([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]){
        UITapGestureRecognizer *ges = (UITapGestureRecognizer *)gestureRecognizer;
        UITapGestureRecognizer *other = (UITapGestureRecognizer *)otherGestureRecognizer;
        if([ges.view isKindOfClass:[UIView class]] && [other.view isKindOfClass:[UITableView class]]){
            return YES; //允许多事件；
        }else{
            return NO; //阻止多事件
        }
    }
    
    return YES; //点击的点的坐标,找到最附近的点；之后再将用户包含附近点的名字的 移动到第一项目；
}

#pragma mark - PanGesture
- (void)panScroll:(UIGestureRecognizer*)gestureRecognizer{
    
//    UIView *filterView = [self.view viewWithTag:8888];
//    if(filterView){
//        return ;
//    }
    
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan){
        
        startSpanPoint = [gestureRecognizer locationInView:self.view]; //取到开始位置的坐标，；
        
        if(self.tableView.frame.origin.y == self.listViewMinTop){
            bBottom_Top_Flag = NO; //记录初始事件，mapView的状态；由上拉到下；
            if(self.tableView.contentOffset.y<0){
                self.tableView.scrollEnabled = NO;
            }else{
                self.tableView.scrollEnabled = YES;
            }
        }else{
            bBottom_Top_Flag = YES; //记录初始事件，mapView的状态；由下推到上；
            self.tableView.scrollEnabled = NO;
        }
        
        
    }else if(gestureRecognizer.state == UIGestureRecognizerStateEnded){
        
        if(pointB1_Y == 1){
            //往上推，没有推到顶部时候，手势结束时候 自动推到顶部；
            NSLog(@"往上推结束时候，到顶部了；");
            [UIView animateWithDuration:0.2 animations:^{
                
                CGRect tableViewFrame = self.tableView.frame;
                tableViewFrame.origin.y = self.listViewMinTop;
                self.tableView.frame = tableViewFrame;
                self.styleView.alpha = 1;
                
            } completion:^(BOOL finished) {
                self.tableView.scrollEnabled = YES;
            }];
            
        }else{
            
            if(self.tableView.contentOffset.y<=0 && self.tableView.frame.origin.y < self.mapViewHeight){
                //往下滑动,只有，排除表格已滚动状态；
                NSLog(@"往下拉结束时候，到底了；");
                [UIView animateWithDuration:0.2 animations:^{
                    
                    CGRect tableViewFrame = self.tableView.frame;
                    tableViewFrame.origin.y = self.mapViewHeight;
                    self.tableView.frame = tableViewFrame;
                    self.styleView.alpha = 0;
                    
                } completion:^(BOOL finished) {
                    self.tableView.scrollEnabled = NO;
                }];
            }
        }
        
        pointB1_Y = 0; //重置方向
        blChange = NO; //重置状态是一直一个方向；
        
    }else{
        CGPoint point = [gestureRecognizer locationInView:self.view];
        
        CGFloat topDistance = startSpanPoint.y - point.y;
        if(topDistance >0){ //>100 就是向上滑，但是要控制滑动的距离限制；
            
            if(pointB1_Y == -1){
                blChange = YES; //记录从往下变成往上；
            }else if(pointB1_Y == 0){
                blChange = NO; //方向没有变更；
            }
            
            pointB1_Y = 1; //记录当前是往上推；
            
            //往上推；
            if(self.tableView.frame.origin.y == self.listViewMinTop){
                self.tableView.scrollEnabled = YES;
            }else{
                
                if(self.datas.count > 0){ //无数据时候 不给往上推
                    
                    //方式一： 向上；上剩多少留多少 ;
                    if(bBottom_Top_Flag == NO){
                        if(!blChange && self.mapViewHeight - topDistance >= self.listViewMinTop){
                            
                            CGRect tableViewFrame = self.tableView.frame;
                            tableViewFrame.origin.y = self.mapViewHeight - topDistance;
                            self.tableView.frame = tableViewFrame;
                        }
                    }else{
                        if(self.mapViewHeight - topDistance >= self.listViewMinTop){
                            
                            CGRect tableViewFrame = self.tableView.frame;
                            tableViewFrame.origin.y = self.mapViewHeight - topDistance;
                            self.tableView.frame = tableViewFrame;
                        }
                    }
                }
            }
            
        }else if(topDistance<0){
            
            if(pointB1_Y == 1){
                blChange = YES; //记录从往上变成往下；
            }else if(pointB1_Y == 0){
                blChange = NO; //方向没有变更；
            }
            pointB1_Y = -1; //记录当前是往下拉；
            
            if(self.tableView.contentOffset.y<=0 && self.tableView.frame.origin.y < self.mapViewHeight){ //并且是在顶部小于0时候
                
                self.tableView.contentOffset = CGPointMake(0, 0); //可写可不写；
                self.tableView.scrollEnabled = NO;
                
                if(bBottom_Top_Flag == YES){
                    if(!blChange && self.listViewMinTop - topDistance <= self.mapViewHeight){
                        
                        CGRect tableViewFrame = self.tableView.frame;
                        tableViewFrame.origin.y = self.listViewMinTop - topDistance;
                        self.tableView.frame = tableViewFrame;
                    }
                }else{
                    if(self.listViewMinTop - topDistance <= self.mapViewHeight){
                        
                        CGRect tableViewFrame = self.tableView.frame;
                        tableViewFrame.origin.y = self.listViewMinTop - topDistance;
                        self.tableView.frame = tableViewFrame;
                    }
                }
            }
        }
    }
}



@end
