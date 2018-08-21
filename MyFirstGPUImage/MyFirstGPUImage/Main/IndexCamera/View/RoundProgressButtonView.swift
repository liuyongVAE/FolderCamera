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
    private var progressLayer:CAShapeLayer!
    private var time:Timer?
    private var progress:CGFloat = 0.0
    private var width:CGFloat = 0.0
    //动画调用间隔
    private var animationTime:CGFloat = 0.0
    //动画调用增量
    private var animationIncr:CGFloat = 0.0
    private var duration:Int? = 2
    var centerViewWidth:CGFloat = 55
    var ifRecord:Bool = false
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
        centerView.addGestureRecognizer(tap)
        outView.addSubview(centerView)
        width = 5
        progressLayer = CAShapeLayer()
        outView.layer.addSublayer(progressLayer)
        progressLayer.fillColor = nil
        progressLayer.lineCap = kCALineCapSquare//线端点类型
        progressLayer.frame = outView.bounds
        progressLayer.lineWidth = width
        progressLayer.strokeColor = UIColor.red.cgColor
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
            self.updateProgress()
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
    }
    
    func addIntervalPath(){
        let progressLayer2 = CAShapeLayer()
        outView.layer.addSublayer(progressLayer)
        progressLayer2.fillColor = nil
        progressLayer2.lineCap = kCALineCapSquare//线端点类型
        progressLayer2.frame = outView.bounds
        progressLayer2.lineWidth = width
        progressLayer2.strokeColor = UIColor.white.cgColor
    
        let progressPath = UIBezierPath(arcCenter: centerView.center, radius: (outView.frame.size.width - (1.5*width))/3, startAngle: CGFloat(Double.pi*2)*progress + CGFloat(-Double.pi/2), endAngle:CGFloat(Double.pi*2)*(progress+0.05) + CGFloat(-Double.pi/2) , clockwise: true)
        progress = progress+0.05

        progressLayer2.path = progressPath.cgPath
    }

    
    
    //MAKR: - Action
    func start(){
        time = Timer.scheduledTimer(timeInterval: TimeInterval(animationTime), target: self, selector: #selector(addProgress), userInfo: nil, repeats: true)
        //RunLoop.current.add(time!, forMode: .commonModes)
        //RunLoop.current.run()
    }
    
    func stop(){
        time?.invalidate()
        time = nil
        UIView.animate(withDuration: 0.3, animations: {
            self.centerView.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.outView.transform = CGAffineTransform(scaleX: 1, y: 1)
        })
        setDuratuin(10)
        setProgress()
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
              //  addIntervalPath()
                touchRecord(isRecord: false)
            }else{
                start()
                touchRecord(isRecord: true)
            }
            UIView.animate(withDuration: 0.3, animations: {
                self.centerView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                self.outView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            })
        default:
            break
        }
    }
    
    func pauseRecord(){
        //pauseTime = time
        time?.invalidate()
        time = nil
    }
    
    func resume(){
        //time = pauseTime
    }
    
 
    
    
}

