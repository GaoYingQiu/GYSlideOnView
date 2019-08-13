//
//  ViewController.m
//  GYSlideOnView
//
//  Updated by qiugaoying on 2019/08/13.
//  Copyright © 2019年 qiugaoying. All rights reserved.
//

#import "ViewController.h"
#import <Masonry.h>
#import "GYShadeView.h"

#define SCREEN_H  [UIScreen mainScreen].bounds.size.height
#define LStatusBarHeight                [[UIApplication sharedApplication] statusBarFrame].size.height
#define LNavBarHeight                   44.0

typedef enum : NSInteger {
    PointDirectTop,
    PointDirectLevel,
    PointDirectBottom,
} PointDirect;

typedef enum : NSInteger {
    SlideDirectBottomToTop,
    SlideDirectTopToBottom,
} SlideDirect;


@interface ViewController ()<UITableViewDelegate, UITableViewDataSource,UIGestureRecognizerDelegate>
{
    CGPoint startSpanPoint;
    PointDirect pointDirect;
    SlideDirect slideDirect;
    BOOL directHasChange ;
    CGFloat panViewMaxY;
    CGFloat panViewMinY;
}

@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,strong) NSMutableArray *datas;
@property(nonatomic,strong) GYShadeView *styleView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"GYSlideOnView";
    _datas = [[NSMutableArray alloc]init];
    pointDirect = PointDirectLevel;
    slideDirect = SlideDirectTopToBottom;
    panViewMaxY = self.view.frame.size.height * 0.65;
    panViewMinY = 95;
  
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
    _tableView.backgroundColor              = [UIColor whiteColor];
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
        make.top.mas_equalTo(self->panViewMaxY);
        make.left.mas_equalTo(7);
        make.right.mas_equalTo(-7); //考虑到手势会触摸在屏幕
    make.height.equalTo(@(SCREEN_H-self->panViewMinY-(LStatusBarHeight+44)));
    }];
 
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
    return YES;
}

#pragma mark - PanGesture
- (void)panScroll:(UIGestureRecognizer*)gestureRecognizer{
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            {
                startSpanPoint = [gestureRecognizer locationInView:self.view];
                
                if(self.tableView.frame.origin.y == panViewMinY){
                    slideDirect = SlideDirectTopToBottom;
                    if(self.tableView.contentOffset.y<0){
                        self.tableView.scrollEnabled = NO;
                    }else{
                        self.tableView.scrollEnabled = YES;
                    }
                }else{
                    slideDirect = SlideDirectBottomToTop;
                    self.tableView.scrollEnabled = NO;
                }
            }
            break;
            
        case UIGestureRecognizerStateEnded:
        {
            if(pointDirect == PointDirectTop){
                
                [UIView animateWithDuration:0.25 animations:^{
                    
                    CGRect tableViewFrame = self.tableView.frame;
                    tableViewFrame.origin.y = self->panViewMinY;
                    self.tableView.frame = tableViewFrame;
                    self.styleView.alpha = 1;
                    
                } completion:^(BOOL finished) {
                    self.tableView.scrollEnabled = YES;
                }];
                
            }else{
                
                if(self.tableView.contentOffset.y<=0 && self.tableView.frame.origin.y < panViewMaxY){
                    
                    [UIView animateWithDuration:0.25 animations:^{
                        CGRect tableViewFrame = self.tableView.frame;
                        tableViewFrame.origin.y = self->panViewMaxY;
                        self.tableView.frame = tableViewFrame;
                        self.styleView.alpha = 0;
                    } completion:^(BOOL finished) {
                        self.tableView.scrollEnabled = NO;
                    }];
                }
            }
            
            pointDirect = PointDirectLevel;
            directHasChange = NO;
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint point = [gestureRecognizer locationInView:self.view];
            CGFloat distance = startSpanPoint.y - point.y;
            [self panGesChange:distance];
        }
            break;
        default:
            break;
    }
   
}


-(void)panGesChange:(CGFloat)distance
{
    if(distance >0){
        
        if(pointDirect == PointDirectBottom){
            directHasChange = YES;
        }else if(pointDirect == PointDirectLevel){
            directHasChange = NO;
        }
        pointDirect = PointDirectTop;
    
        if(self.tableView.frame.origin.y == panViewMinY){
            self.tableView.scrollEnabled = YES;
        }else{
            
            CGRect tableViewFrame = self.tableView.frame;
            CGFloat directTopY =  panViewMaxY - distance;
            if (directTopY >= panViewMinY) {
                if(slideDirect == SlideDirectBottomToTop){
                    tableViewFrame.origin.y = directTopY;
                }else {
                    if(!directHasChange){
                        tableViewFrame.origin.y = directTopY;
                    }
                }
                 self.tableView.frame = tableViewFrame;
            }
        }
        
    }else if(distance<0){
        
        if(pointDirect == PointDirectTop){
            directHasChange = YES;
        }else if(pointDirect == PointDirectLevel){
            directHasChange = NO;
        }
        pointDirect = PointDirectBottom;
        
        if(self.tableView.contentOffset.y<=0 && self.tableView.frame.origin.y < panViewMaxY){
            
            self.tableView.contentOffset = CGPointMake(0, 0);
            self.tableView.scrollEnabled = NO;
            CGRect tableViewFrame = self.tableView.frame;
            
            CGFloat directBottomY = panViewMinY - distance ;
            if (directBottomY <= panViewMaxY){
                  if(slideDirect == SlideDirectBottomToTop){
                      if(!directHasChange){
                          tableViewFrame.origin.y = directBottomY;
                      }
                  }else{
                       tableViewFrame.origin.y = directBottomY;
                  }
            }
            self.tableView.frame = tableViewFrame;
        }
    }
}


@end
