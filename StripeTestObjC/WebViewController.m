//
//  WebViewController.m
//  Together
//
//  Created by Kenneth Transier on 11/14/14.
//  Copyright (c) 2014 Kenneth Transier. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController () <UIWebViewDelegate>

    @property (weak, nonatomic) IBOutlet UIWebView *webView;
    - (void)loadRequestFromString:(NSString*)urlString;

@end

@implementation WebViewController

    - (void)viewDidLoad {
        [super viewDidLoad];
        // Do any additional setup after loading the view.
        
        [self loadRequestFromString:self.url];

    }

    - (void)didReceiveMemoryWarning {
        [super didReceiveMemoryWarning];
        // Dispose of any resources that can be recreated.
    }

    - (void)loadRequestFromString:(NSString*)urlString
    {
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
        [self.webView loadRequest:urlRequest];
        self.webView.scalesPageToFit = YES;
    }

    - (void)webViewDidStartLoad:(UIWebView *)webView {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }

    - (void)webViewDidFinishLoad:(UIWebView *)webView {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }

    - (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
    {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }

    - (void)didMoveToParentViewController:(UIViewController *)parent
    {
        if (![parent isEqual:self.parentViewController]) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }
    }

@end
