import 'package:email_otp/email_otp.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_club/firebase_options.dart';
import 'package:flutter_club/showcase_project/bloc/login_bloc.dart';
import 'package:flutter_club/showcase_project/college_rec.dart';
import 'package:flutter_club/showcase_project/login_project.dart';
import 'package:flutter_club/showcase_project/onboard_project.dart';
import 'package:flutter_club/showcase_project/scholarship_rec.dart';
import 'package:flutter_club/showcase_project/tracker.dart';
import 'package:flutter_club/widgettree.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    // DeviceOrientation.portraitDown,
  ]);
  await Hive.initFlutter();
  await Hive.openBox("tasks_box");
  await Hive.openBox("email_pass");

  await EmailOTP.config(
    appEmail: "muhammadtaqiulla@gmail.com",
    appName: "Level Up",
    otpType: OTPType.numeric,
    otpLength: 5,
    expiry: 300000,
  );

  String template =
      '''
<div style="font-family: 'Arial', sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; background: linear-gradient(135deg, #0A0A0A 0%, #001122 100%); border-radius: 20px; box-shadow: 0 10px 30px rgba(0, 194, 255, 0.3); border: 1px solid #00C2FF;">
  <div style="text-align: center; padding: 30px 20px;">
    
    <!-- Techy Header with Logo/Image -->
    <div style="margin-bottom: 25px;">
    
      <h2 style="color: #00C2FF; font-size: 28px; font-weight: bold; margin: 10px 0; font-family: 'Courier New', monospace; text-transform: uppercase; letter-spacing: 2px;">
        SECURITY VERIFICATION
      </h2>
    </div>

    <!-- Main Content -->
    <div style="background: rgba(255, 255, 255, 0.05); padding: 30px; border-radius: 15px; border: 1px solid #00C2FF; margin-bottom: 25px;">
      <p style="font-size: 16px; color: #e0e0e0; text-align: center; margin-bottom: 20px; line-height: 1.6;">
        <strong style="color: #00C2FF;">ACCESS REQUEST DETECTED</strong><br>
        Hello agent, your verification code for <strong style="color: #00C2FF;">{{appName}}</strong> is ready.
      </p>

      <!-- OTP Display - Techy Style -->
      <div style="text-align: center; margin: 30px 0;">
        <div style="display: inline-block; background: rgba(0, 194, 255, 0.1); padding: 20px 40px; border-radius: 12px; border: 2px solid #00C2FF; position: relative; overflow: hidden;">
          <!-- Corner dots for circuit board effect -->

          
          <span style="font-size: 42px; font-weight: bold; color: #00C2FF; font-family: 'Courier New', monospace; letter-spacing: 8px; text-shadow: 0 0 10px rgba(0, 194, 255, 0.5);">
            {{otp}}
          </span>
        </div>
      </div>

      <!-- Instructions -->
      <div style="background: rgba(0, 0, 0, 0.3); padding: 20px; border-radius: 10px; margin: 25px 0;">
        <p style="font-size: 22px; color: #cccccc; text-align: center; margin: 0; line-height: 1.5;">
          <strong>CODE EXPIRES IN:</strong> 5 MINUTES<br>
        </p>
      </div>
    </div>

    <!-- Footer -->
    <div style="border-top: 1px solid #00C2FF; padding-top: 20px;">
      <p style="font-size: 12px; color: #666666; text-align: center; margin-bottom: 10px;">
        This is an automated security message from {{appName}}
      </p>
      <p style="font-size: 11px; color: #444444; text-align: center;">
        © ${DateTime.now().year} Level Up Security Systems • All access monitored
      </p>
    </div>

   
  </div>
</div>
''';

  // Replace the year placeholder
  template = template.replaceAll(
    '${DateTime.now().year}',
    DateTime.now().year.toString(),
  );

  // Set it
  EmailOTP.setTemplate(template: template);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(402, 874),
      child: MultiBlocProvider(
        providers: [BlocProvider(create: (context) => LoginBloc())],
        child: MaterialApp(
          home: HomeProject(),
          theme: ThemeData(brightness: Brightness.dark),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
