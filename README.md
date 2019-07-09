JKRComplexFallsDemo
==============
[![preview](https://travis-ci.org/Joker-388/MessageImageCategory.svg?branch=master)](http://www.jianshu.com/u/95d5ea0acd19)&nbsp;<br><br>
[![preview](https://github.com/Joker-388/JKRComplexFallsDemo/blob/master/fall.gif)](http://www.jianshu.com/u/95d5ea0acd19)&nbsp;
<br><br>

接口：
```
https://www.easy-mock.com/mock/5cff89e36c54457798010709/shop/finderlist
```

数据：
```
{
  "data": [
    {
      "img": "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1561019906083&di=2bbf7db2124067fe80739cce43a2b00e&imgtype=0&src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201410%2F05%2F20141005095943_QY5e8.jpeg",
      "width": "1200",
      "height": "2249"
    },
    {
      "img": "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1561020045178&di=56eb95088ce1a23bbd16776ebcedb837&imgtype=0&src=http%3A%2F%2Fhbimg.b0.upaiyun.com%2Fc8107b13c3bfd1fa8835f5dc80c541b64c6b9e901a8f7-RLJBJP_fw658",
      "width": "658",
      "height": "872"
    },
    ...
    {
      "img": "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1561020635692&di=cd0dedd961380917af46c536e7f6600b&imgtype=0&src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201707%2F29%2F20170729215622_tTLBP.thumb.700_0.jpeg",
      "width": "700",
      "height": "701"
    }
  ]
}
```

每个图片数据都指定了图片的宽和高，由于需要放大，而被放大占用两列宽度的图片顶部必须要对齐，所以需要将高度差别不大的两列高度做矫正。

* 插入图片的高度距离左右某一张的高度差值小于的它高度20%就将图片高度强行对齐高度。
* 每一排不允许出现连续两个放大的图片。
* 每一列不允许出现连续连个放大的图片。
* 使用网络接口数据
* 瀑布流使用图片定义尺寸
* 支持上下拉刷新
* 支持自定义列数
* 支持自定义图片间距
* 支持自定义外边框距
