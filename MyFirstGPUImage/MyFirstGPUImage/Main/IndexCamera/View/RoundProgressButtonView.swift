//
//  RoundProgressButtonViewController.swift
//  MyFirstGPUImage
//
//  Created by LiuYong on 2018/8/8.
//  Copyright © 2018年 LiuYong. All rights reserved.
//

import UIKit


@objc protocol ProgresssButtonDelegate{
    func videoControl(control:RoundProgressButtonView,gest:UIGestureRecognizer)
    func touchRecordButton(isRecord:Bool)
    func finishRecordLongVideo()
}
class RoundProgressButtonView:UIView{

    private var outView:UIView!
    private var centerView:UIView!
    //直线进度条
    let progressLineLayer:CAShapeLayer = CAShapeLayer()
    //圆形
    private var progressLayer:CAShapeLayer!
    private var time:Timer?
    private var progress:CGFloat = 0.0
    //长视频录制变量
    private var progressPause:[CGFloat]? = [CGFloat]()
    private var width:CGFloat = 0.0
    //进度条暂停间隔
    private var  whiteOverlay = [CAShapeLayer]()

    //动画调用间隔
    private var animationTime:CGFloat = 0.0
    //动画调用增量
    private var animationIncr:CGFloat = 0.0
    private var duration:Int? = 2
    var centerViewWidth:CGFloat = 55
    var ifRecord:Bool = false
    var ifLivePhoto:Bool = false

    var ifLongRecord:Bool?{
        didSet{
           setDuratuin(30)
        }
    }
    var timeCounter = 0.0
    var pauseTime:Timer?
    lazy var tipLabel:UILabel = {
        let label = UILabel()
       // label.text = "长按拍照键录制"
        label.font = UIFont.systemFont(ofSize: 12)
        label.sizeToFit()
        return label
    }()
    
    
    //delegate
    @objc weak var delegate:ProgresssButtonDelegate?

    //设置持续时间
    func setDuratuin(_ duration:Int){
        self.duration = duration
        // _duration = 10 时，为，0.01秒一刷新
        // 每次增加的增量为 0.001
        animationTime = 1/CGFloat(duration*duration)
        animationIncr = 1/CGFloat(duration*duration*duration)
    }
    
    override init(frame:CGRect){
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setUI(){
        self.backgroundColor = UIColor.clear
        outView = UIView(frame: self.bounds)
        outView.layer.cornerRadius = self.bounds.size.width/2
        outView.backgroundColor = naviColor
        outView.alpha = 0.7
        self.addSubview(outView)
        centerView = UIView(frame: CGRect(x:0,y:0,width:centerViewWidth,height:centerViewWidth))
        centerView.backgroundColor = UIColor.white
        centerView.layer.cornerRadius = centerViewWidth/2
        centerView.center = outView.center
        centerView.isUserInteractionEnabled = true
        let longpress = UILongPressGestureRecognizer(target: self, action: #selector(self.longPress(_:)))
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapAction(_:)))
        centerView.addGestureRecognizer(longpress)
        self.addGestureRecognizer(tap)
        outView.addSubview(centerView)
        width = 5
        progressLayer = CAShapeLayer()
        outView.layer.addSublayer(progressLayer)
        progressLayer.fillColor = nil
        progressLayer.lineCap = kCALineCapSquare//线端点类型
        progressLayer.frame = outView.bounds
        progressLayer.lineWidth = width
        progressLayer.strokeColor = lightPink.cgColor
        self.addSubview(tipLabel)
        tipLabel.snp.makeConstraints({
            make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(self.snp.top).offset(-20)
        })
        

        setProgress()
        //设置持续时间默认值
        setDuratuin(10)
    }
    //MAKR: - 事件处理
    
    /// 长按事件处理
    ///根据不同的长按事件，进行动画效果,并且传给视频页
    /// - Parameter logressPress: 长按事件
    @objc func longPress(_ logressPress:UIGestureRecognizer){
        if ifLongRecord ?? false {
            return
        }
        if delegate != nil{
            delegate?.videoControl(control: self, gest: logressPress)
        }
        switch logressPress.state {
        case .began:
            //点击开始时，外部缩放内部缩小do
            self.start()
            UIView.animate(withDuration: 0.3, animations: {
                self.centerView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                self.outView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            })
            
        case .cancelled:
            stop()
        case .ended:
            UIView.animate(withDuration: 0.3, animations: {
                self.centerView.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.outView.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
            stop()
            
        default:
            break
        }
    }
    
    //视频按钮点击
    ///
    ///
    /// - Parameter isRecord: true表示要开始录制，false暂停
    func touchRecord(isRecord:Bool){
        delegate?.touchRecordButton(isRecord: isRecord)
    }
    
    
    
    /// 触摸点击事件
    ///
    /// - Parameter gest: 触摸
    @objc func tapAction(_ gest:UIGestureRecognizer){
        //判断是否在拍摄长视频
        if ifLongRecord ?? false {
            tapPress(gest as! UITapGestureRecognizer)
        }
        
        if delegate != nil && !(ifLongRecord ?? false){
            delegate?.videoControl(control: self, gest: gest)
        }
        
    }
    
    
    @objc func addProgress(){
        //主线程添加,控制进度
        DispatchQueue.main.async {
            //print(self.progress)
            self.progress = self.progress +  self.animationIncr
            if !(self.ifLongRecord ?? false){
            self.updateProgress()
            }
            self.updateLinePath()
            if self.progress > 1{
                self.stop()
            }
        }
    }

    //MARK: - Progress
    func setProgress(){
        progress = 0
        let progressPath = UIBezierPath(arcCenter: centerView.center, radius: (outView.frame.size.width - (1.5*width))/3, startAngle: CGFloat(Double.pi/2*3), endAngle: CGFloat(-Double.pi/2), clockwise: true)
        //定义完贝塞尔曲线，添加到layer
        progressLayer.path = progressPath.cgPath
    }
    func updateProgress(){
        timeCounter =  0.01 + timeCounter
        let progressPath = UIBezierPath(arcCenter: centerView.center, radius: (outView.frame.size.width - (1.5*width))/3, startAngle: CGFloat(Double.pi/2*3), endAngle: CGFloat(Double.pi*2)*progress + CGFloat(-Double.pi/2), clockwise: true)
        //定义完贝塞尔曲线，添加到layer，更新path
        progressLayer.path = progressPath.cgPath
        progressLayer.strokeColor = lightPink.cgColor

    }
    

    
    
    //MAKR: - Action
    func start(){
        if ifLongRecord ?? false{
            setDuratuin(30)
            setLinePath()
        }else if !ifLivePhoto{
            setDuratuin(10)
        }else{
            setDuratuin(3)
        }
        
        time = Timer.scheduledTimer(timeInterval: TimeInterval(animationTime), target: self, selector: #selector(addProgress), userInfo: nil, repeats: true)
        //RunLoop.current.add(time!, forMode: .commonModes)
        //RunLoop.current.run()
    }
    //停止录制
    func stop(){
        time?.invalidate()
        time = nil
        UIView.animate(withDuration: 0.3, animations: {
            self.centerView.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.outView.transform = CGAffineTransform(scaleX: 1, y: 1)
        })
        for i in whiteOverlay{
            i.removeFromSuperlayer()
        }
        //setDuratuin(10)
        setProgress()
        setLinePath()
    }
    
    func reStartCount(){
        timeCounter = 0.0
    }
}
//MARK: - 断点拍摄
extension RoundProgressButtonView{
    
 
    func tapPress(_ tap:UITapGestureRecognizer){
        switch tap.state {
        case .began:
            print("beginTap")
        case .ended:
            if time != nil{
                pauseRecord()
                addIntervalPath()
                touchRecord(isRecord: false)
                UIView.animate(withDuration: 0.3, animations: {
                    self.centerView.transform = CGAffineTransform(scaleX: 1, y: 1)
                    self.outView.transform = CGAffineTransform(scaleX: 1, y: 1)
                })
            }else{
                start()
                progressPause?.append(progress)
                touchRecord(isRecord: true)
                UIView.animate(withDuration: 0.3, animations: {
                    self.centerView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                   // self.outView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                })
            }
      
        default:
            break
        }
    }
    
    func pauseRecord(){
        pauseTime = time
        time?.invalidate()
        time = nil
    }
    
    //删除上一段
    func deletrLast(){
        //time = pauseTime
       // let progressPath = UIBezierPath(arcCenter: centerView.center, radius: (outView.frame.size.width - (1.5*width))/3, startAngle: CGFloat(Double.pi*2)*(progressPause?.last ?? 0) + CGFloat(-Double.pi/2), endAngle:CGFloat(Double.pi*3)/2, clockwise: true)
        //progressPath.stroke()
        progressLayer.strokeColor = naviColor.cgColor
        //progressLayer.path = progressPath.cgPath
        progress = (progressPause?.last  ?? progress ) - 0.015
        //print(progress,progressPause ?? progress)
        //updateProgress()
        updateLinePath()
        if let c = progressPause?.count,c>0{
           progressPause?.removeLast()
        }
        if whiteOverlay.count>0{
            whiteOverlay.last?.removeFromSuperlayer()
            whiteOverlay.removeLast()
        }
        
    }
    
}
//直线进度条
extension RoundProgressButtonView{
    func setLinePath(){
        progressLineLayer.fillColor = nil
        progressLineLayer.lineCap = kCALineCapSquare//线端点类型
        progressLineLayer.frame = CGRect.init(x: -152, y: -543, width: SCREEN_WIDTH, height: 5)
        progressLineLayer.lineWidth = width
        progressLineLayer.strokeColor = bgColor.cgColor
        let progressPath = UIBezierPath()
        progressPath.move(to: CGPoint(x:0,y:0))
        progressPath.addLine(to: CGPoint(x:0,y:0))
        outView.layer.addSublayer(progressLineLayer)
        
            //UIBezierPath(arcCenter: centerView.center, radius: (outView.frame.size.width - (1.5*width))/3, startAngle: CGFloat(Double.pi*2)*progress + CGFloat(-Double.pi/2), endAngle:CGFloat(Double.pi*2)*(progress+0.0005) + CGFloat(-Double.pi/2) , clockwise: true)
       // progress = progress+0.0005
        progressLineLayer.path = progressPath.cgPath
    }
    
    
    func addIntervalPath(){
        let progressLayer2 = CAShapeLayer()
        progressLayer2.fillColor = nil
        progressLayer2.lineCap = kCALineCapButt//线端点类型
        progressLayer2.frame = CGRect.init(x: -152, y: -543, width: SCREEN_WIDTH, height: 5)
        progressLayer2.lineWidth = width
        progressLayer2.strokeColor = UIColor.white.cgColor
        progressLayer2.zPosition = 2
        whiteOverlay.append(progressLayer2)
        let progressPath = UIBezierPath()
        progressPath.move(to: CGPoint(x:SCREEN_WIDTH*(progress+0.005),y:0))
        // let progressPath = UIBezierPath(arcCenter: centerView.center, radius: (outView.frame.size.width - (1.5*width))/3, startAngle: CGFloat(Double.pi*2)*progress + CGFloat(-Double.pi/2), endAngle:CGFloat(Double.pi*2)*(progress+0.0005) + CGFloat(-Double.pi/2) , clockwise: true)
        progress = progress+0.01
        progressPath.addLine(to: CGPoint(x:progress*SCREEN_WIDTH,y:0))
        progress = progress+0.005
        // progressPath.stroke()
        whiteOverlay.last?.path = progressPath.cgPath
        outView.layer.addSublayer(whiteOverlay.last!)
 
    }
    
    func updateLinePath(){
        let progressPath = UIBezierPath()
        progressPath.move(to: CGPoint(x:0,y:0))
        progressPath.addLine(to: CGPoint(x:progress*SCREEN_WIDTH,y:0))
        progressLineLayer.path = progressPath.cgPath
    }
    
    //滤镜页面升起时，调用此方法将进度条移动到顶部
    func moveLine(){
        progressLineLayer.frame = CGRect.init(x: -152, y: -583, width: SCREEN_WIDTH, height: 5)
        for i in whiteOverlay{
            i.frame = CGRect.init(x: -152, y: -583, width: SCREEN_WIDTH, height: 5)
        }

    }
    //重设进度条位置
    func reSetLine(){
        progressLineLayer.frame = CGRect.init(x: -152, y: -543, width: SCREEN_WIDTH, height: 5)
        for i in whiteOverlay{
            i.frame = CGRect.init(x: -152, y: -543, width: SCREEN_WIDTH, height: 5)
        }

    }
    
    
}


