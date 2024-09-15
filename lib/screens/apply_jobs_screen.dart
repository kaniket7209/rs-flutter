import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:right_ship/screens/home_page_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auto_size_text_field/auto_size_text_field.dart';

class ApplyJobsScreen extends StatefulWidget {
   ApplyJobsScreen({super.key, required this.application,required this.employee_id, required this.applyJobs, required this.unapplyJobs, required this.saveJobs, required this.unsaveJobs,});

  final Map<String, dynamic> application;
  final String employee_id;
  // final VoidCallback btnOnTap;
  // final VoidCallback iconTap;
  final Future<void> Function() applyJobs;
  final Future<void> Function() unapplyJobs;
  final Future<void> Function() saveJobs;
  final Future<void> Function() unsaveJobs;


  @override
  State<ApplyJobsScreen> createState() => _ApplyJobsScreenState();
}

class _ApplyJobsScreenState extends State<ApplyJobsScreen> {
  String btnText = "Apply";
  IconData usedIcon = Icons.bookmark_border_outlined;

  @override
  void initState() {
    super.initState();
    _initializeButtonTextAndIcon();
  }

  void _initializeButtonTextAndIcon() {
    bool isAppliedByExist = widget.application['applied_by'] != null && widget.application['applied_by'].isNotEmpty;
    bool isAppliedByUser = isAppliedByExist && widget.application['applied_by'].any((appliedBy) => appliedBy['employee_id'] == widget.employee_id);

    setState(() {
      btnText = isAppliedByUser ? "Unapply" : "Apply";
      usedIcon = (widget.application['save_jobs_applications'] ?? []).any((saveJobs) => saveJobs['employee_id'] == widget.employee_id)
          ? Icons.bookmark
          : Icons.bookmark_border_outlined;
    });
  }

  void buttonOnTapFunctionality() async {
    bool isAppliedByExist = widget.application['applied_by'] != null && widget.application['applied_by'].isNotEmpty;
    bool isMatched = isAppliedByExist && widget.application['applied_by'].any((appliedBy) => appliedBy['employee_id'] == widget.employee_id);

    if (isMatched) {
      await widget.unapplyJobs();
      setState(() {
        btnText = 'Apply';
      });
    } else {
      await widget.applyJobs();
      setState(() {
        btnText = 'Unapply';
      });
    }

    // Reinitialize button text and icon after API call
    _initializeButtonTextAndIcon();
  }

  void iconTapFunctionality() async {
    bool isAppliedByExist = widget.application['save_jobs_applications'] != null && widget.application['save_jobs_applications'].isNotEmpty;
    bool isMatched = isAppliedByExist && widget.application['save_jobs_applications'].any((savejobs) => savejobs['employee_id'] == widget.employee_id);

    // Optimistically update the icon state before the API call
    setState(() {
      usedIcon = isMatched ? Icons.bookmark_border_outlined : Icons.bookmark;
    });

    try {
      if (isMatched) {
        await widget.unsaveJobs();
      } else {
        await widget.saveJobs();
      }
    } catch (e) {
      // If there's an error, revert the icon to the previous state
      setState(() {
        usedIcon = isMatched ? Icons.bookmark : Icons.bookmark_border_outlined;
      });
      // Optionally show an error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update job status')));
    }
  }


  @override
  Widget build(BuildContext context) {
    final hiringFor = (widget.application['hiring_for'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    final openPositions = (widget.application['open_positions'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    final benefits = (widget.application['benefits'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        leading: Container(
          width: 433,
          height: 74,
          child: SizedBox(
            height: 40,
            width: 40,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, weight: 20),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => HomePageScreen()));
              },
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 5),
            Container(
              color: const Color(0xFFFFFFFF),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 22, left: 36.0, bottom: 23),
                    child: Container(
                      width: 144,
                      height: 123,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(width: 3, color: const Color(0xFF1F5882)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          'assets/images/nature.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Padding(
                    padding: const EdgeInsets.only(top: 21),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         textWidget(widget.application['company_name'] ?? 'N/A', 'Poppins', FontWeight.w600, 15, 0, 0, 0, 0, null,),
                        const SizedBox(height: 2),
                        textWidget(
                          "RPSL No ${widget.application['rspl_no'] ?? 'N/A'}", 'Poppins', FontWeight.w300, 14, 0, 0, 0, 0, const Color(0xFF000000),),
                        const SizedBox(height: 13),
                        Row(
                          children: [
                            SizedBox(
                              height: 35,
                              width: 102,
                              child: ElevatedButton(
                                onPressed: buttonOnTapFunctionality,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4E7CD4),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
                                  ),
                                ),
                                child: textWidget(btnText, 'Inter', FontWeight.w500, 14, 0, 0, 0, 0, Colors.white,),),
                            ),
                            const SizedBox(width: 15),
                            SizedBox(
                              height: 29,
                              width: 29,
                              child:
                              IconButton(
                                icon: Icon(usedIcon),
                                onPressed:iconTapFunctionality,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            Container(
              height: 102,
              width: 433,
              color: const Color(0xFFFFFFFF),
              child: Column(
                children: [
                  IconAndTextRowWidget(
                    22,
                    38,
                    25,
                    15,
                    widget.application['mobile_no'] ?? 'N/A',
                    'Inter',
                    FontWeight.w500,
                    16,
                  ),
                  IconAndTextRowWidget(
                    5,
                    38,
                    5,
                    16,
                    widget.application['email'] ?? 'N/A',
                    'Inter',
                    FontWeight.w500,
                    16,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            Container(
              color: const Color(0xFFFFFFFF),
              width: 433,
              child: Padding(
                padding: const EdgeInsets.only(left: 40, top: 15, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    textWidget(
                      'Hiring For',
                      'Poppins',
                      FontWeight.w500,
                      20,
                      0,
                      0,
                      0,
                      0,
                      null,
                    ),
                    const SizedBox(height: 6),
                    for (var hiring in hiringFor)
                      textWidget(
                        hiring,
                        'Poppins',
                        FontWeight.w400,
                        16,
                        0,
                        0,
                        0,
                        0,
                        null,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 5),
            Container(
              color: const Color(0xFFFFFFFF),
              width: 433,
              child: Padding(
                padding: const EdgeInsets.only(top: 21, left: 39, bottom: 21),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    textWidget(
                      'Open Positions',
                      'Poppins',
                      FontWeight.w500,
                      20,
                      0,
                      0,
                      0,
                      0,
                      null,
                    ),
                    const SizedBox(height: 12),
                    for (var position in openPositions)
                      textWidget(
                        position,
                        'Poppins',
                        FontWeight.w400,
                        16,
                        2,
                        0,
                        0,
                        0,
                        null,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 5),
            Container(
              color: const Color(0xFFFFFFFF),
              width: 433,
              child: Padding(
                padding: const EdgeInsets.only(top: 21, left: 39, bottom: 21),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    textWidget(
                      'Benefits',
                      'Poppins',
                      FontWeight.w500,
                      20,
                      0,
                      0,
                      0,
                      0,
                      null,
                    ),
                    const SizedBox(height: 12),
                    for (var benefit in benefits)
                      textWidget(
                        benefit,
                        'Poppins',
                        FontWeight.w400,
                        16,
                        2,
                        0,
                        0,
                        0,
                        null,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  Row IconAndTextRowWidget(double topIconPadding,double leftIconPadding,double topTextPadding,double leftTextPadding,String val,String fontFamily,FontWeight fw, double fontSize) {
    return Row(
      children: [
        Padding(
          padding:  EdgeInsets.only(top:topIconPadding,left: leftIconPadding,),
          child: Container(height: 25,width: 25,color: const Color(0xFFD9D9D9)),
        ),
        Padding(
          padding:  EdgeInsets.only(top: topTextPadding,left: leftTextPadding),
          child:  Text(val,style: TextStyle(fontFamily: fontFamily,fontWeight: fw,fontSize: fontSize,),),
        )
      ],
    );
  }

  Padding textWidget(String val,String fontFamily,FontWeight fw, double? fontSize, double top,double left,double bottom,double right,Color? color) {
    return Padding(
      padding: EdgeInsets.only(top: top,left: left,bottom: bottom,right: right),
      child: Text(val,style: TextStyle(fontFamily: fontFamily,fontWeight: fw,fontSize: fontSize,color: color),
      ),
    );
  }
}
