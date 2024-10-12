%---------------------9x9均值滤波模糊处理-------------------
clc;         %清空控制台
clear;       %清空工作区
close all;   %关闭已打开的figure图像窗口
color_pic=imread('BlackMythScreenshotBmpTest.bmp');  %读取彩色图像
gray_pic=rgb2gray(color_pic);    %将彩色图转换成灰度图
double_gray_pic=im2double(gray_pic);   %将uint8转成im2double型便于后期计算
[width,height]=size(double_gray_pic);
H=fspecial('average',9);  %生成9x9均值滤波器,图像更模糊，3x3几乎看不出差别
degrade_img1=imfilter(double_gray_pic, H, 'conv', 'circular');  %使用卷积滤波，默认是相关滤波

%--------------------在均值滤波模糊图像基础上添加椒盐噪声------------------
degrade_img2=imnoise(degrade_img1,'salt & pepper',0.05);  %给退化图像1添加噪声密度为0.05的椒盐噪声(退化图像2)
figure('name','退化图像');
subplot(2,2,1);imshow(color_pic,[]);title('原彩色图');
subplot(2,2,2);imshow(double_gray_pic,[]);title('原灰度图');
subplot(2,2,3);imshow(degrade_img1,[]);title('退化图像1');
subplot(2,2,4);imshow(degrade_img2,[]);title('退化图像2');

%-------------------------对退化图像1逆滤波复原-------------------------
fourier_H=fft2(H,width,height);  %注意此处必须得让H从9x9变成与原图像一样的大小此处为512x512，否则ifft2 ./部分会报错矩阵不匹配
fourier_degrade_img1=fft2(degrade_img1);    %相当于 G(u,v)=H(u,v)F(u,v)，已知G(u,v),H(u,v)，求F(u,v)
restore_one=ifft2(fourier_degrade_img1./fourier_H);  %因为是矩阵相除要用./  
figure('name','退化图像1逆滤波复原');
subplot(1,2,1);imshow(im2uint8(degrade_img1),[]);title('退化图像1');
subplot(1,2,2);imshow(im2uint8(restore_one),[]);title('复原图像1');

%-------------------------对退化图像2直接逆滤波复原-------------------------
fourier_degrade_img2=fft2(degrade_img2); %相当于 G(u,v)=H(u,v)F(u,v)+N(u,v)
restore_two=ifft2(fourier_degrade_img2./fourier_H);

%------------------------去掉噪声分量逆滤波复原-----------------------
noise=degrade_img2-degrade_img1;   %提取噪声分量
fourier_noise=fft2(noise);   %对噪声进行傅里叶变换
restore_three=ifft2((fourier_degrade_img2-fourier_noise)./fourier_H);  %G(u,v)=H(u,v)F(u,v)+N(u,v),解得F(u,v)=[G(u,v)-N(u,v)]/H(u,v)
figure('name','退化图像2逆滤波复原');
subplot(2,2,1);imshow(double_gray_pic,[]);title('原灰度图');
subplot(2,2,2);imshow(im2uint8(degrade_img2),[]);title('退化图像2');
subplot(2,2,3);imshow(im2uint8(restore_two),[]);title('直接逆滤波复原');
subplot(2,2,4);imshow(im2uint8(restore_three),[]);title('去掉噪声分量逆滤波复原');