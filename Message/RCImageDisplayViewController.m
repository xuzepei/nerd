//
//  RCImageDisplayViewController.m
//  Message
//
//  Created by xuzepei on 8/7/14.
//  Copyright (c) 2014 TapGuilt Inc. All rights reserved.
//

#import "RCImageDisplayViewController.h"
#import "Item.h"

@interface RCImageDisplayViewController ()

@end

@implementation RCImageDisplayViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        UIBarButtonItem* leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(clickedLeftBarButtonItem:)];
        
        self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    
        UIBarButtonItem* rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(clickedRightBarButtonItem:)];
        
        self.navigationItem.rightBarButtonItem = rightBarButtonItem;
        
        self.title = @"图片";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickedLeftBarButtonItem:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (IBAction)clickedRightBarButtonItem:(id)sender
{
    [self saveToPhotoLibrary];
}

- (CGSize)getFitImageSize:(CGSize)size
{
    CGFloat image_width = [RCTool getScreenSize].width - 20.0f;
    CGFloat image_height = [RCTool getScreenSize].height - 40.0f - NAVIGATION_BAR_HEIGHT - STATUS_BAR_HEIGHT;
    
    CGFloat width = size.width;
    CGFloat height = size.height;
    
    if(size.width >= size.height)
    {
        while (width > image_width){
            
            width--;
            
            height = size.height*width/size.width;
        }
    }
    else
    {
        while (width > image_width || height > image_height){
            
            height--;
            
            width = size.width*height/size.height;
        }
    }
    
    return CGSizeMake(width, height);
}

- (void)updateContent:(Item*)item
{
    self.theItem = item;
    if(nil == _scrollView)
    {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, [RCTool getScreenSize].width, [RCTool getScreenSize].height - NAVIGATION_BAR_HEIGHT - STATUS_BAR_HEIGHT)];
        //_scrollView.backgroundColor = [UIColor redColor];
        _scrollView.delegate = self;
    }
    
    [self.view addSubview:_scrollView];
    
    NSString* imageUrl = item.imgurl;
    
    UIImage* image = [RCTool getImageFromLocal:imageUrl];
    if(nil == image)
        return;
    
    NSString* imagePath = [RCTool getImageLocalPath:imageUrl];
    if(nil == _gifImageView)
    {
        CGSize size = [self getFitImageSize:image.size];
        _gifImageView = [[YLImageView alloc] initWithFrame:CGRectMake(([RCTool getScreenSize].width - size.width)/2.0, 20.0f, size.width, size.height)];
        _gifImageView.image = [YLGIFImage imageWithContentsOfFile:imagePath];
        _gifImageView.userInteractionEnabled = YES;
    }
    
    [_scrollView addSubview:_gifImageView];

    
    _scrollView.minimumZoomScale = 0.5;
    _scrollView.maximumZoomScale = 20.0;
    
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _gifImageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
    [scrollView setZoomScale:scale animated:NO];
}

- (void)centerScrollViewContents {
    
    CGSize boundsSize = self.scrollView.bounds.size;
    CGRect contentsFrame = _gifImageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    _gifImageView.frame = contentsFrame;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self centerScrollViewContents];
}

- (void)saveToPhotoLibrary
{
    if(nil == _theItem)
        return;
    
    UIImage* image = [RCTool getImageFromLocal:_theItem.imgurl];
    if(nil == image)
        return;
    
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if(nil == error)
    {
        [RCTool showAlert:@"提示" message:@"图片已成功保存到本地相册！"];
    }
    else
    {
        [RCTool showAlert:@"提示" message:@"图片保存失败！"];
    }
}

@end
