//
//  Header.h
//  FolderCamera
//
//  Created by LiuYong on 2018/8/10.
//  Copyright © 2018年 LiuYong. All rights reserved.
//




 //这两个是输入,表示输入图片的像素
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 //main函数里面对像素进行处理
 void main()
 {
     //这个textureColor就是结合了输入之后,表示图片像素的vec4
     lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     //w即透明度
     //这样就能让rgb的输入变成+0.5,也就是让亮度+0.5
     gl_FragColor = vec4((textureColor.rgb + vec3(0.5)), textureColor.w);
 }
 
