import 'package:flutter/material.dart';
import 'package:due_tocoffee/routes/screen_export.dart';
import 'logout_util.dart';
import 'component/language_page.dart';
import 'package:easy_localization/easy_localization.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.25),
                offset: Offset(0, 4),
                blurRadius: 4,
              ),
            ],
          ),
          padding: const EdgeInsets.only(
            left: 9,
            top: 10,
            bottom: 64,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 47),
                width: 419,
                height: 120,
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(100),
                    bottomRight: Radius.circular(100),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.25),
                      offset: Offset(2, 4),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child:
                    const ProfileInfo(), // ProfileInfo is now properly placed inside
              ),
              Container(
                margin: const EdgeInsets.only(top: 51),
                width: 409,
                height: 136,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.25),
                      offset: Offset(2, 5),
                      blurRadius: 4,
                      spreadRadius: 4,
                    ),
                  ],
                ),
              ),
              ..._buildUserBarList(context),
            ],
          ),
        ),
      ),
    );
  }

  // Helper untuk handle image loading dengan error boundary
  Widget _buildNetworkImage(String url,
      {required double width, required double height}) {
    return Image.network(
      url,
      width: width,
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: const Icon(Icons.broken_image, color: Colors.red),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return SizedBox(
          width: width,
          height: height,
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
    );
  }

  List<Widget> _buildUserBarList(BuildContext context) {
    return [
      ListTile(
        title: Text("my_order_payments".tr()),
        onTap: () => Navigator.pushNamed(context, '/orderPayments'),
      ),
      ListTile(
        title: Text("settings".tr()),
        onTap: () => Navigator.pushNamed(context, '/settings'),
      ),
      ListTile(
        title: Text("choose_language".tr()),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LanguagePage()),
        ),
      ),
      ListTile(
        title: Text("help_support".tr()),
        onTap: () => Navigator.pushNamed(context, '/support'),
      ),
      ListTile(
        title: Text("logout".tr()),
        onTap: () => showLogoutConfirmation(context),
      ),
    ];
  }
}
