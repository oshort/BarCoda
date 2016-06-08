//
//  ViewController.m
//  BarCoda
//
//  Created by Oliver Short on 6/8/16.
//  Copyright © 2016 Oliver Short. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController () <AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic,strong) UIView *previewView;
@property (nonatomic,strong) AVCaptureSession *session;
@property (nonatomic,strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.session = [[AVCaptureSession alloc]init];
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.previewView = [[UIView alloc]initWithFrame:CGRectMake(20, 20, 200, 200)];
    
    [self.view addSubview:self.previewView];
    [self.previewView.layer addSublayer:self.previewLayer];
    
    self.previewLayer.videoGravity = AVLayerVideoGravityResize;
    
    NSArray* devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice* camera = nil;
    for (AVCaptureDevice* device in devices) {
        if(device.position == AVCaptureDevicePositionBack){
            camera = device;
        }
    }
    NSError *error = nil;
    AVCaptureDeviceInput * cameraInput = [[AVCaptureDeviceInput alloc]initWithDevice:camera error:&error];
    AVCaptureMetadataOutput* output = [[AVCaptureMetadataOutput alloc]init];
    if (cameraInput == nil) {
        NSLog(@"%@", [error localizedDescription]);
    }else{
        [self.session addInput:cameraInput];
        [self.session addOutput:output];
    }
    
    NSSet* potentialDataTypes = [NSSet setWithArray:
                                @[
                                  AVMetadataObjectTypeQRCode,
                                  AVMetadataObjectTypeEAN8Code,
                                  AVMetadataObjectTypeEAN13Code,
                                  ]
                                 ];
    
    NSMutableArray *supportedMetaDataTypes = [NSMutableArray array];
    for (NSString* availableMetaDataType in output.availableMetadataObjectTypes) {
        if ([potentialDataTypes containsObject:availableMetaDataType]) {
            [supportedMetaDataTypes addObject: availableMetaDataType];
        }
    }
    
    [output setMetadataObjectTypes:supportedMetaDataTypes];
    [output setMetadataObjectsDelegate:self queue: dispatch_get_main_queue()];
    
    [self.session startRunning];
}

-(void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.previewLayer.frame = self.previewView.bounds;
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    NSLog(@"%@",metadataObjects);
    
    self.textView.text = [metadataObjects description];
}

@end
