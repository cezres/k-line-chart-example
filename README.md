# K-line Chart Example

使用 `CustomPainter` 自绘K线图。

**[K线 Web 桌面端演示页面](https://flutter-k-line-chart-example.github.io/)** (由于跨域使用固定时段数据)。

### 如何运行

```bash
$ flutter pub get
$ flutter run
```

### 截图


macOS|Web|iOS
:-|:-|:-
![img](https://github.com/cezres/K-line-chart-example/blob/main/assets/desktop.png) | ![img](https://github.com/cezres/K-line-chart-example/blob/main/assets/web.png) | ![img](https://github.com/cezres/K-line-chart-example/blob/main/assets/mobile.png)



-----


**在后台执行计算任务并大量传递数据时，复用 Isolate 并使用 TransferableTypedData 传递数据会有更好的性能**，[测试方法](https://github.com/cezres/k-line-chart-example/blob/main/test/widget_test.dart#L19)。



```bash
1. Use compute:
time:2952	result:150005000
✓ Test performance of Isolate 1. Use compute
2. Reuse Isolate and use SendPort to send data:
time:2146	result:150005000
✓ Test performance of Isolate 2. Reuse Isolate and use SendPort to send data
3. Send TransferableTypedData:
time:1832	result:150005000
✓ Test performance of Isolate 3. Send TransferableTypedData
```