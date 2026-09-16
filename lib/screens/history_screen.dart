import 'package:flutter/material.dart';

import '../models/analysis_history.dart';


class HistoryScreen extends StatefulWidget {
  final List<AnalysisHistory> history;

  const HistoryScreen({
    super.key,
    required this.history,
  });

  @override
  State<HistoryScreen> createState() =>
      _HistoryScreenState();
}


class _HistoryScreenState
    extends State<HistoryScreen> {


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFFF5F7F4),


      appBar: AppBar(

        title: const Text(
          "Analysis History",
        ),

        backgroundColor:
            const Color(0xFFF5F7F4),

        foregroundColor:
            const Color(0xFF234B2A),

        elevation: 0,

      ),


      body: widget.history.isEmpty

          ? const Center(

              child: Column(

                mainAxisAlignment:
                    MainAxisAlignment.center,

                children: [

                  Icon(

                    Icons.history,

                    size: 80,

                    color:
                        Color(0xFF5E7D63),

                  ),

                  SizedBox(height: 20),

                  Text(

                    "No Analysis History",

                    style: TextStyle(

                      fontSize: 22,

                      fontWeight:
                          FontWeight.bold,

                      color:
                          Color(0xFF234B2A),

                    ),

                  ),

                  SizedBox(height: 10),

                  Text(

                    "Your scanned plants will appear here.",

                    style: TextStyle(

                      fontSize: 15,

                      color:
                          Colors.grey,

                    ),

                  ),

                ],

              ),

            )


          : ListView.builder(

              padding:
                  const EdgeInsets.all(16),

              itemCount:
                  widget.history.length,

              itemBuilder:
                  (context, index) {

                final item =
                    widget.history[index];


                return Card(

                  margin:
                      const EdgeInsets.only(
                    bottom: 14,
                  ),

                  elevation: 2,

                  shape:
                      RoundedRectangleBorder(

                    borderRadius:
                        BorderRadius.circular(16),

                  ),


                  child: Padding(

                    padding:
                        const EdgeInsets.all(16),

                    child: Column(

                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        Row(

                          children: [

                            Container(

                              padding:
                                  const EdgeInsets.all(10),

                              decoration:
                                  BoxDecoration(

                                color:
                                    const Color(
                                  0xFFE4F0E5,
                                ),

                                borderRadius:
                                    BorderRadius.circular(
                                  12,
                                ),

                              ),

                              child: const Icon(

                                Icons.eco,

                                color:
                                    Color(
                                  0xFF2F6B3A,
                                ),

                              ),

                            ),


                            const SizedBox(
                              width: 12,
                            ),


                            Expanded(

                              child: Column(

                                crossAxisAlignment:
                                    CrossAxisAlignment.start,

                                children: [

                                  Text(

                                    item.plantName,

                                    style:
                                        const TextStyle(

                                      fontSize: 20,

                                      fontWeight:
                                          FontWeight.bold,

                                      color:
                                          Color(
                                        0xFF234B2A,
                                      ),

                                    ),

                                  ),


                                  const SizedBox(
                                    height: 4,
                                  ),


                                  Text(

                                    item.scientificName,

                                    style:
                                        const TextStyle(

                                      fontSize: 14,

                                      fontStyle:
                                          FontStyle.italic,

                                      color:
                                          Colors.grey,

                                    ),

                                  ),

                                ],

                              ),

                            ),

                          ],

                        ),


                        const SizedBox(
                          height: 16,
                        ),


                        const Divider(),


                        const SizedBox(
                          height: 8,
                        ),


                        Row(

                          children: [

                            const Icon(

                              Icons.bug_report,

                              color:
                                  Color(0xFFB23B3B),

                            ),

                            const SizedBox(
                              width: 8,
                            ),

                            Expanded(

                              child: Text(

                                item.disease,

                                style:
                                    const TextStyle(

                                  fontSize: 17,

                                  fontWeight:
                                      FontWeight.w600,

                                ),

                              ),

                            ),

                          ],

                        ),


                        const SizedBox(
                          height: 12,
                        ),


                        Row(

                          children: [

                            Expanded(

                              child: _InfoBox(

                                title:
                                    "Disease Confidence",

                                value:
                                    "${item.diseaseConfidence.toStringAsFixed(1)}%",

                              ),

                            ),


                            const SizedBox(
                              width: 10,
                            ),


                            Expanded(

                              child: _InfoBox(

                                title:
                                    "Severity",

                                value:
                                    item.severity,

                              ),

                            ),

                          ],

                        ),


                        const SizedBox(
                          height: 12,
                        ),


                        Text(

                          "Analyzed: "
                          "${item.dateTime.day}/"
                          "${item.dateTime.month}/"
                          "${item.dateTime.year}",

                          style:
                              const TextStyle(

                            color:
                                Colors.grey,

                            fontSize:
                                13,

                          ),

                        ),

                      ],

                    ),

                  ),

                );

              },

            ),

    );

  }

}


class _InfoBox extends StatelessWidget {

  final String title;

  final String value;


  const _InfoBox({

    required this.title,

    required this.value,

  });


  @override
  Widget build(BuildContext context) {

    return Container(

      padding:
          const EdgeInsets.all(12),

      decoration:
          BoxDecoration(

        color:
            const Color(0xFFF1F5F1),

        borderRadius:
            BorderRadius.circular(12),

      ),


      child: Column(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Text(

            title,

            style:
                const TextStyle(

              fontSize:
                  12,

              color:
                  Colors.grey,

            ),

          ),


          const SizedBox(
            height: 5,
          ),


          Text(

            value,

            style:
                const TextStyle(

              fontSize:
                  16,

              fontWeight:
                  FontWeight.bold,

              color:
                  Color(0xFF234B2A),

            ),

          ),

        ],

      ),

    );

  }

}