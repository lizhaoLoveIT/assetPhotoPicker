//
//  GetPhotoViewController.m
//  多图片选择框架的使用
//
//  Created by 李朝 on 16/5/6.
//  Copyright © 2016年 IFengXY. All rights reserved.
//

#import "GetPhotoViewController.h"

@interface GetPhotoViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation GetPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)pickPhotos:(id)sender {
    // 弹出 alertView 来让用户选择
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:(UIAlertControllerStyleActionSheet)];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"打开照相机" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [self openCamera];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"从手机相册中获取" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [self openAlbum];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

/**
 * 通过照相机获取一张图片
 */
- (void)openCamera
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    /**
     *  UIImagePickerControllerSourceType
     *
     *  SourceType pickerController 的类型
     *  UIImagePickerControllerSourceTypePhotoLibrary,     从 所有 相册中选择
     *  UIImagePickerControllerSourceTypeCamera,           弹出照相机
     *  UIImagePickerControllerSourceTypeSavedPhotosAlbum  从 moment 相册中选择
     */
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

/**
 * 打开用户相册 获取一张图片
 */
- (void)openAlbum
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    /**
     *  UIImagePickerControllerSourceType
     *
     *  SourceType pickerController 的类型
     *  UIImagePickerControllerSourceTypePhotoLibrary,     从 所有 相册中选择
     *  UIImagePickerControllerSourceTypeCamera,           弹出照相机
     *  UIImagePickerControllerSourceTypeSavedPhotosAlbum  从 moment 相册中选择
     */
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    self.imageView.image = info[UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
