
@property(nonatomic, strong) AVPlayerLayer *videoLayer;

- (void)viewDidLoad {
  [super viewDidLoad];

  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(replayVideo:)
             name:AVPlayerItemDidPlayToEndTimeNotification
           object:nil];

  [contentLayer addSublayer:self.videoLayer];
  [self.view.layer insertSublayer:contentLayer atIndex:0];
}

- (AVPlayerLayer *)videoLayer {
  if (!_videoLayer) {

    NSString *movieRelativePath = @"img/background-video.mp4";
    NSString *movieAbsolutePath = [(CDVCommandDelegateImpl *)_commandDelegate
        pathForResource:movieRelativePath];
    NSURL *movieURL = [NSURL fileURLWithPath:movieAbsolutePath];

    _videoLayer = [AVPlayerLayer
        videoLayerWithPlayer:[[AVPlayer alloc] initWithURL:movieURL]];
    _videoLayer.frame = CGRectMake(0, 0, self.view.frame.size.width,
                                   self.view.frame.size.height);

    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(replayMovie:)
               name:AVPlayerItemDidPlayToEndTimeNotification
             object:[_videoLayer.player currentItem]];

    [_videoLayer.player play];
  }
  return _videoLayer
}

- (void)replayVideo:(NSNotification *)notification {
  [self.videoLayer.player play];
}

- (void)setPosition:(CDVInvokedUrlCommand *)command {
  NSArray *arguments = command.arguments;
  NSNumber *offsetX = [arguments objectAtIndex:0];
  NSNumber *offsetY = [arguments objectAtIndex:1];
  playerLayer.position =
      CGPointMake([offsetX doubleValue], [offsetY doubleValue]);
}
