import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:right_ship/screens/home_page_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApplyJobsScreen extends StatefulWidget {
   ApplyJobsScreen({super.key, required this.application,required this.employee_id,required this.btnOnTap, required this.applyForJob, required this.unApplyForJob,  required this.iconTap,});

  final Map<String, dynamic> application;
  // String btnText;
  final String employee_id;
  final VoidCallback btnOnTap;
  final VoidCallback applyForJob;
  final VoidCallback unApplyForJob;
  // IconData usedIcon;
  final VoidCallback iconTap;

  @override
  State<ApplyJobsScreen> createState() => _ApplyJobsScreenState();
}

class _ApplyJobsScreenState extends State<ApplyJobsScreen> {

  bool ispressed = false;
  String btnText = "Apply";
  IconData usedIcon = Icons.bookmark_border_outlined;

  @override
  Widget build(BuildContext context) {

    setState(() {
      // Check if 'applied_by' is not empty
      bool isAppliedByExist = widget.application['applied_by'] != null && widget.application['applied_by'].isNotEmpty;
      // Determine the button text based on employee_id comparison

      if (isAppliedByExist) {
        btnText = widget.application['applied_by'].any((appliedBy) =>
        appliedBy['employee_id'] == widget.employee_id) ? "Unapply" : "Apply";
      }

      //check if 'save_jobs_applications' is not empty
      bool isSavedJobExist = widget.application['save_jobs_applications'] != null && widget.application['save_jobs_applications'].isNotEmpty;
      if(isSavedJobExist){
        usedIcon = widget.application['save_jobs_applications'].any((saveJobs) =>
        saveJobs['employee_id'] == widget.employee_id) ? Icons.bookmark : Icons.bookmark_border_outlined;
      }

    });

    final hiringFor = (widget.application['hiring_for'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    final openPositions =   (widget.application['open_positions'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    final benefits =  (widget.application['benefits'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];


    return Scaffold(
      appBar: AppBar(backgroundColor: const Color(0xFFFFFFFF),
        leading: Container(
            width: 433,height: 74,
            child:  SizedBox(height: 40,width: 40,
              child:
                  IconButton(
                    icon: const Icon(Icons.arrow_back, weight: 20),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => HomePageScreen()));
                    },
                  ),

            )
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 5,),
            Container(
              // height: 168,width: 433,
              color: const Color(0xFFFFFFFF),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 22,left: 36.0,bottom: 23),
                    child: Container(
                        width: 144,height: 123,decoration: BoxDecoration(borderRadius: BorderRadius.circular(16),border: Border.all(width: 3,color: const Color(0xFF1F5882))),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset('assets/images/nature.png',fit: BoxFit.cover,)
                        )
                    ),
                  ),
                  const SizedBox(width: 15,),
                  Padding(
                    padding: const EdgeInsets.only(top: 21),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        textWidget(widget.application['company_name'] ?? 'N/A', 'Poppins', FontWeight.w500, 24, 0, 0,0,0,null),
                        const SizedBox(height: 2,),
                        textWidget("RPSL No ${widget.application['rspl_no'] ?? 'N/A'}", 'Poppins', FontWeight.w300, 14, 0, 0,0,0, const Color(0xFF000000)),
                        const SizedBox(height: 13,),
                        Row(
                          children: [
                            SizedBox(height: 35,width: 102,
                              child: ElevatedButton(onPressed: widget.btnOnTap,
                                style: ElevatedButton.styleFrom(backgroundColor:const Color(0xFF4E7CD4),shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
                                  child: textWidget(
                                      btnText,
                                      'Inter', FontWeight.w500, 14, 0, 0, 0, 0,Colors.white )),
                            ),
                            const SizedBox(width: 15,),
                            SizedBox(height: 29,width: 29,
                                child: IconButton(icon: Icon(usedIcon), onPressed: widget.iconTap,))
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 5,),
            Container(height: 102,width: 433, color: const Color(0xFFFFFFFF),
              child: Column(
                children: [
                  IconAndTextRowWidget(22,38,25,15,widget.application['mobile_no'] ?? 'N/A','Inter',FontWeight.w500,16),
                  IconAndTextRowWidget(5, 38, 5, 16,widget.application['email'] ?? 'N/A', 'Inter', FontWeight.w500, 16)

                ],
              ),
            ),
            const SizedBox(height: 5,),
            Container(
                color: const Color(0xFFFFFFFF),
                width: 433,
                child:  Padding(
                  padding: const EdgeInsets.only(left: 40,top: 15,bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      textWidget('Hiring For', 'Poppins', FontWeight.w500, 20, 0, 0, 0, 0, null),
                      const SizedBox(height: 6,),
                      for(var hiring in hiringFor)
                        textWidget(hiring, 'Poppins', FontWeight.w400, 16,  0, 0, 0, 0, null)
                    ],
                  ),
                )
            ),
            const SizedBox(height: 5,),
            Container(color: const Color(0xFFFFFFFF),
                width: 433,
                child:  Padding(
                  padding: const EdgeInsets.only(top: 21,left: 39,bottom:21 ,right: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      textWidget('Open Positions','Poppins',FontWeight.w500,20,0,0,0,0,null),
                      const SizedBox(height: 12,),
                      for(var position in openPositions)
                         textWidget(position, 'Poppins', FontWeight.w400, 16, 2, 0,0,0,null),
                    ],
                  ),
                )
            ),
            const SizedBox(height: 5,),
            Container(color: const Color(0xFFFFFFFF),
               width: 433,
                child:  Padding(
                  padding: const EdgeInsets.only(top: 21,left: 39,bottom:21,right: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      textWidget('Benifits','Poppins',FontWeight.w500,20,0,0,0,0,null),
                      const SizedBox(height: 12,),
                      for (var benefit in benefits)
                        textWidget(benefit, 'Poppins', FontWeight.w400, 16, 2, 0, 0, 0, null),
                    ],
                  ),
                )
            ),
            const SizedBox(height: 5,),
            Container(color: const Color(0xFFFFFFFF),
                width: 433,
                child:  Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    textWidget('Description', 'Poppins', FontWeight.w500, 20, 21, 39, 0, 0, null),
                    textWidget(widget.application['description'], 'Poppins', FontWeight.w400, 16, 11, 38, 15, 39, null)
                  ],
                )
            )
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
