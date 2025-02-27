import 'package:flutter/material.dart';
import 'recognition.dart';
import 'box_widget.dart';
import 'camera_settings.dart';
import 'camera_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  /// Results to draw bounding boxes
  List<Recognition>? results;

  /// Realtime stats
  int totalElapsedTime = 0;

  /// Scaffold Key
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          '쭈미로운 생활 객체 인식 예제',
          style: TextStyle(
              fontWeight: FontWeight.w600, color: Colors.white, fontSize: 15),
        ),
      ),
      body: Stack(
        children: [
          CameraView(resultsCallback, updateElapsedTimeCallback),
          boundingBoxes(results),
          Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  resultsList(results),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        statsRow('이미지 추론 시간:', '$totalElapsedTime ms'),
                        statsRow('이미지 크기',
                            '${CameraSettings.inputImageSize?.width} X ${CameraSettings.inputImageSize?.height}'),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Returns Stack of bounding boxes
  Widget boundingBoxes(List<Recognition>? results) {
    if (results == null) {
      return Container();
    }
    return Stack(
      children: results
          .map((e) => BoxWidget(
                result: e,
              ))
          .toList(),
    );
  }

  Widget resultsList(List<Recognition>? results) {
    if (results == null) {
      return Container();
    }
    return SizedBox(
      height: 120,
      child: ListView.builder(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        itemCount: results.length,
        itemBuilder: (context, index) {
          return Container(
            height: 20,
            child: ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${(index + 1)}. 객체명: ${results[index].label}',
                      style: TextStyle(fontSize: 13)),
                  Text(
                      '예츨확률: ${(results[index].score! * 100).toStringAsFixed(1)} %',
                      style: TextStyle(fontSize: 13)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Callback to get inference results from [CameraView]
  void resultsCallback(List<Recognition> results) {
    setState(() {
      this.results = results;
    });
  }

  void updateElapsedTimeCallback(int elapsedTime) {
    setState(() {
      totalElapsedTime = elapsedTime;
    });
  }
}

/// Row for one Stats field
Padding statsRow(left, right) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(left), Text(right)],
    ),
  );
}
