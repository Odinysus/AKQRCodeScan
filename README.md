# AKQRCodeScan
an qrcode reader example which look like wechat QRCode scan , using AVFoundation with Objective-C
## Further
* smooth  
`[self.session startRunning]` may cost many times. So it execute in asynchronous progress, which add/remove input, add/remove output. but `AVCaptureVideoPreviewLayer` initialization will put in main queue. `UIActivityIndicatorView` will show animation when you present the view controller, until the `session` is running.
* authorization  
it always check the authorization status after `viewDidLoad` and `viewDidAppear`. it will stop current session because the authorization will influence it.  
* widthOfInterest  
`AVCaptureVideoPreviewLayer` will fill the screen. you can set the `widthOfInterest`. because the the area we scan is an square in the screen center.  
* code of photo  
you can recognize the qrcode form photo which u pich with `UIImagePickerController'

need to do:
* drag the `AKQrcodeViewController` to your project. import `AKQrcodeViewController.h` in your head file. and set the `codeBlock`  

        codeBlock = ^(NSString value) { NSLog(@"the qrcode is %@", value); }

option:
* if you want to add an button which can change the font camera fatten , in the top right corner.  

          hiddenChnageButton = NO;

* if you want to change the scan area width (default is 80% of screen size width)  

        widthOfInterest = [UIScreen mainScreen].bounds.size.width * 0.8;

detail info to see my blog:[iOS中的二维码](http://www.jianshu.com/p/3f05e63d9ada)  


---

这是一个模仿微信扫描二维码的例子.并对几个细节进行控制:  
* **卡顿** 由于`[self.session startRunning]`可能会花费比较长的时间.可能会发费0.5s,会有一个卡顿的现象.session的初始化和配置都放在异步线程中.但是有关`previewLayer`的操作要放在主线程中更新.并在加载时显示`UIActivityIndicatorView`动画.
* **权限** 在`viewDidLoad`和`viewDidAppear`中添加权限的检测和权限的获取.在获取权限和`viewDidDisappear`之前,必须将当前的`session`暂停.
* **扫描区域** 上面的整个代码中,默认扫描整一个`layer`.像微信这些app都只扫描中间的部分区域.`AVCaptureVideoPreviewLayer`中有属性`rectOfInterest`,控制我们所扫描的区域.默认值为(0.0, 0.0, 1.0, 1.0).不过`AVCaptureVideoPreviewLayer`有很多一个简便的方法计算这个百分比`metadataOutputRectOfInterestForRect:`,通过坐标计算比例,利用这个方法可以快速计算百分比.   
* **图片中的二维码**   
可以从相册中选择图片并识别图片中的二维码.

你需要做的:  
* 将`AKQrcodeViewController`文件夹拖进你的项目中,并导入头文件`AKQrcodeViewController.h`,然后设置`codeBlock`  

        codeBlock = ^(NSString value) { NSLog(@"the qrcode is %@", value); }

可选项:  
* 设置是否位于右上角的显示切换按钮(可切换前摄像头扫描)

        hiddenChnageButton = NO;

* 如果你想要改变中间的扫描区域的宽度(默认是屏幕宽度的80%的正方形)  

        widthOfInterest = [UIScreen mainScreen].bounds.size.width * 0.8;

更多详情请查看我的博客[iOS中的二维码](http://www.jianshu.com/p/3f05e63d9ada)  
