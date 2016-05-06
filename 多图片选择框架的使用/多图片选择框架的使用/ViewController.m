//
//  ViewController.m
//  多图片选择框架的使用
//
//  Created by 李朝 on 16/5/4.
//  Copyright © 2016年 IFengXY. All rights reserved.
//

#import "ViewController.h"
#import "GetPhotoViewController.h"
#import "MultiPickerViewController.h"

#import <Photos/Photos.h>

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - UI交互
#pragma mark -

- (IBAction)pickMultiPhotos:(id)sender {
    MultiPickerViewController *multiPickerVc = [[MultiPickerViewController alloc] init];
    [self presentViewController:multiPickerVc animated:YES completion:nil];
}


- (IBAction)gotoGetPhotoVc:(id)sender {
    GetPhotoViewController *getPhotoVc = [[GetPhotoViewController alloc] init];
    [self presentViewController:getPhotoVc animated:YES completion:nil];
}


- (IBAction)saveImageToAlbum:(id)sender {
    // 获取 当前 App 对 phots 的访问权限
    PHAuthorizationStatus OldStatus = [PHPhotoLibrary authorizationStatus];
    
    // 检查访问权限 当前 App 对相册的检查权限
    /**
     * PHAuthorizationStatus
     * PHAuthorizationStatusNotDetermined = 0, 用户还未决定
     * PHAuthorizationStatusRestricted,        系统限制，不允许访问相册 比如家长模式
     * PHAuthorizationStatusDenied,            用户不允许访问
     * PHAuthorizationStatusAuthorized         用户可以访问
     * 如果之前已经选择过，会直接执行 block，并且把以前的状态传给你
     * 如果之前没有选择过，会弹框，在用户选择后调用 block 并且把用户的选择告诉你
     * 注意：该方法的 block 在子线程中运行 因此，弹框什么的需要回到主线程执行
     */
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (status == PHAuthorizationStatusAuthorized) {
                //            [self cSaveToCameraRoll];
                //            [self photoSaveToCameraRoll];
                //            [self fetchCameraRoll];
                //            [self createCustomAssetCollection];
                //            [self createdAsset];
                //            [self saveImageToCustomAlbum2];
                [self saveImageToCustomAlbum1];
            } else if (OldStatus != PHAuthorizationStatusNotDetermined && status == PHAuthorizationStatusDenied) {
                // 用户上一次选择了不允许访问 且 这次又点击了保存 这里可以适当提醒用户允许访问相册
            }
        });
    }];
}


#pragma mark - 将图片保存到自定义相册中 第二种写法 直接保存 placeholder 到自定义相册
#pragma mark -

- (void)saveImageToCustomAlbum2
{
    // 将图片保存到相机胶卷
    NSError *error = nil;
    __block PHObjectPlaceholder *placeholder = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        placeholder = [PHAssetChangeRequest creationRequestForAssetFromImage:self.imageView.image].placeholderForCreatedAsset;
    } error:&error];
    if (error) {
        NSLog(@"保存失败");
    }
    // 获取自定义相册
    PHAssetCollection *createdCollection = [self createCustomAssetCollection];
    
    // 将图片保存到自定义相册
    /**
     * 必须通过中间类，PHAssetCollectionChangeRequest 来完成
     * 步骤：1.首先根据相册获取 PHAssetCollectionChangeRequest 对象
     *      2.然后根据 PHAssetCollectionChangeRequest 来添加图片
     * 这一步的实现有两个思路：1.通过上面的占位 asset 的标识来获取 相机胶卷中的 asset
     *                       然后，将 asset 添加到 request 中
     *                     2.直接将 占位 asset 添加到 request 中去也是可行的
     */
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:createdCollection];
//        [request addAssets:@[placeholder]];
        [request insertAssets:@[placeholder] atIndexes:[NSIndexSet indexSetWithIndex:0]];
    } error:&error];
    if (error) {
        NSLog(@"保存失败");
    } else {
        NSLog(@"保存成功");
    }
}

#pragma mark - 将图片保存到自定义相册中 第一种写法 比较规范
#pragma mark -

- (void)saveImageToCustomAlbum1
{
    // 获取保存到相机胶卷中的图片
    PHAsset *createdAsset = [self createdAssets].firstObject;
    if (createdAsset == nil) {
        NSLog(@"保存图片失败");
    }
    // 获取自定义相册
    PHAssetCollection *createdCollection = [self createCustomAssetCollection];
    if (createdCollection == nil) {
        NSLog(@"创建相册失败");
    }
    
    NSError *error = nil;
    // 将图片保存到自定义相册
    /**
     * 必须通过中间类，PHAssetCollectionChangeRequest 来完成
     * 步骤：1.首先根据相册获取 PHAssetCollectionChangeRequest 对象
     *      2.然后根据 PHAssetCollectionChangeRequest 来添加图片
     * 这一步的实现有两个思路：1.通过上面的占位 asset 的标识来获取 相机胶卷中的 asset
     *                       然后，将 asset 添加到 request 中
     *                     2.直接将 占位 asset 添加到 request 中去也是可行的
     */
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:createdCollection];
        //        [request addAssets:@[placeholder]];
        [request insertAssets:@[createdAsset] atIndexes:[NSIndexSet indexSetWithIndex:0]];
    } error:&error];
    if (error) {
        NSLog(@"保存失败");
    } else {
        NSLog(@"保存成功");
    }
}

#pragma mark - 获取保存到【相机胶卷】的图片
#pragma mark -

- (PHFetchResult<PHAsset *> *)createdAssets
{
    // 将图片保存到相机胶卷
    NSError *error = nil;
    __block NSString *assetID = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        assetID = [PHAssetChangeRequest creationRequestForAssetFromImage:self.imageView.image].placeholderForCreatedAsset.localIdentifier;
    } error:&error];
    if (error) return nil;
    return [PHAsset fetchAssetsWithLocalIdentifiers:@[assetID] options:nil];
}

#pragma mark - 使用 photo 框架创建自定义名称的相册 并获取自定义到自定义相册
#pragma mark -

- (PHAssetCollection *)createCustomAssetCollection
{
    // 获取 app 名称
    NSString *title = [NSBundle mainBundle].infoDictionary[(NSString *)kCFBundleNameKey];
    
    NSError *error = nil;
    
    // 查找 app 中是否有该相册 如果已经有了 就不再创建
    /**
     *     参数一 枚举：
     *     PHAssetCollectionTypeAlbum      = 1, 用户自定义相册
     *     PHAssetCollectionTypeSmartAlbum = 2, 系统相册
     *     PHAssetCollectionTypeMoment     = 3, 按时间排序的相册
     *
     *     参数二 枚举：PHAssetCollectionSubtype
     *     参数二的枚举有非常多，但是可以根据识别单词来找出我们想要的。
     *     比如：PHAssetCollectionTypeSmartAlbum 系统相册 PHAssetCollectionSubtypeSmartAlbumUserLibrary 用户相册 就能获取到相机胶卷
     *     PHAssetCollectionSubtypeAlbumRegular 常规相册
     */
    PHFetchResult<PHAssetCollection *> *result = [PHAssetCollection fetchAssetCollectionsWithType:(PHAssetCollectionTypeAlbum)
                                                                                          subtype:(PHAssetCollectionSubtypeAlbumRegular)
                                                                                          options:nil];
    
    
    for (PHAssetCollection *collection in result) {
        if ([collection.localizedTitle isEqualToString:title]) { // 说明 app 中存在该相册
            return collection;
        }
    }
    
    /** 来到这里说明相册不存在 需要创建相册 **/
    __block NSString *createdCustomAssetCollectionIdentifier = nil;
    // 创建和 app 名称一样的 相册
    /**
     * 注意：这个方法只是告诉 photos 我要创建一个相册，并没有真的创建
     *      必须等到 performChangesAndWait block 执行完毕后才会
     *      真的创建相册。
     */
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        PHAssetCollectionChangeRequest *collectionChangeRequest = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:title];
        /**
         * collectionChangeRequest 即使我们告诉 photos 要创建相册，但是此时还没有
         * 创建相册，因此现在我们并不能拿到所创建的相册，我们的需求是：将图片保存到
         * 自定义的相册中，因此我们需要拿到自己创建的相册，从头文件可以看出，collectionChangeRequest
         * 中有一个占位相册，placeholderForCreatedAssetCollection ，这个占位相册
         * 虽然不是我们所创建的，但是其 identifier 和我们所创建的自定义相册的 identifier
         * 是相同的。所以想要拿到我们自定义的相册，必须保存这个 identifier，等 photos app
         * 创建完成后通过 identifier 来拿到我们自定义的相册
         */
        createdCustomAssetCollectionIdentifier = collectionChangeRequest.placeholderForCreatedAssetCollection.localIdentifier;
    } error:&error];
    
    // 这里 block 结束了，因此相册也创建完毕了
    if (error) return nil;
    
    return [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[createdCustomAssetCollectionIdentifier] options:nil].firstObject;
}

#pragma mark - 使用 photo 获取相机胶卷
#pragma mark -

- (void)fetchCameraRoll
{
    // 获得相机胶卷相册
    PHFetchResult<PHAssetCollection *> *result = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    for (PHAssetCollection *collection in result) {
        NSLog(@"%@", collection.localizedTitle);
    }
}

#pragma mark - 使用 photo 框架将图片保存到相机胶卷中
#pragma mark -

- (void)photoSaveToCameraRoll
{
    /**
     * 该方法是同步执行的。在当前线程 如果执行失败 error 将会有值。
     */
    NSError *error = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        [PHAssetChangeRequest creationRequestForAssetFromImage:self.imageView.image];
    } error:&error];
}

#pragma mark - c 语言函数将图片保存到相机胶卷中
#pragma mark -

- (void)cSaveToCameraRoll
{
    /**
     * 该 c 语言函数是将图片保存到相机胶卷中
     * 第一个参数：image 图片
     * 第二个参数：target
     * 第三个参数：selector 方法名规定使用以下方法名 ：- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
     * 第四个参数：保存完毕后会将第四个参数传给函数调用者
     * 方法作用：将图片保存到相机胶卷中，保存完毕后会调用 target 的 selector 方法
     */
    UIImageWriteToSavedPhotosAlbum(self.imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    // 保存成功或者失败回来到这个地方
}
@end
