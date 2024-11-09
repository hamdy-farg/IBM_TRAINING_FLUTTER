import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:ibm_training_flutter/model.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ViewScreen(),
    );
  }
}

class ViewScreen extends StatefulWidget {
  const ViewScreen({super.key});

  @override
  State<ViewScreen> createState() => _ViewScreenState();
}

class _ViewScreenState extends State<ViewScreen> {
  final PagingController<int, NewsModel> _pagingController =
      PagingController(firstPageKey: 1);
  int counter = 1;
  @override
  void initState() {
    // TODO: implement initState
    _pagingController.addPageRequestListener((pagekey) async {
      await _fetchPage(pagekey);
    });
    super.initState();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      Response request = await Dio().get(
          "https://techcrunch.com/wp-json/wp/v2/posts?context=embed&per_page=5&page=$pageKey");
      counter += 5;
      setState(() {});
      bool isLast = request.data.isEmpty;
      log("1");
      if (isLast) {
        log("2");

        _pagingController.appendLastPage(request.data);
      } else {
        log("23");

        List<NewsModel> newData = List<NewsModel>.from(
            request.data.map((news) => NewsModel(news["slug"], news["id"])));
        log("234");

        final int nextPageKey = pageKey + 1;

        _pagingController.appendPage(newData, nextPageKey);
      }
      // log(request.data); // Check the response data
    } catch (e) {
      log("Error: $e"); // Print any errors that occur
    }
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        Expanded(
          child: LineChart(
            LineChartData(
              titlesData: const FlTitlesData(show: true),
              borderData: FlBorderData(show: true),
              minX: 0,
              maxX: counter.toDouble(),
              minY: 0,
              maxY: counter.toDouble(),
              lineBarsData: [
                LineChartBarData(
                    spots: List.generate(
                  counter,
                  (c) =>
                      FlSpot(c.toDouble(), c.toDouble() - (c.toDouble() / 3)),
                )),
              ],
            ),
          ),
        ),
        Expanded(
          child: PagedListView(
              pagingController: _pagingController,
              builderDelegate: PagedChildBuilderDelegate<NewsModel>(
                  itemBuilder: (context, item, index) {
                return ListTile(
                  title: Text(
                    item.slug,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    item.url.toString(),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              })),
        ),
      ]),
    );
  }
}
