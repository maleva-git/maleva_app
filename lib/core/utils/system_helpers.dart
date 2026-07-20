import 'package:maleva/core/network/api_client.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:maleva/core/colors/colors.dart' as colour;
import 'package:google_fonts/google_fonts.dart';
import 'package:app_version_update/app_version_update.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_barcode_scanner_plus/flutter_barcode_scanner_plus.dart';

class SystemHelpers {

  static Future barcodeScanning() async {
    try {
      AppGlobals.barcodestring = "";
      AppGlobals.barcodeerror = false;
      AppGlobals.barcodestring = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
      if (AppGlobals.barcodestring == '-1') {
        AppGlobals.barcodestring = '';
      }
    } on PlatformException catch (e) {
      Fluttertoast.showToast(
          msg: 'Failed to get platform version: $e',
          textColor: Colors.black,
          fontSize: 18.00,
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: Colors.white,
          gravity: ToastGravity.CENTER);
      // AppGlobals.barcodestring = 'Unknown error: $e';
      debugPrint(e.toString());
      AppGlobals.barcodeerror = true;
    } on FormatException {
      Fluttertoast.showToast(
          msg: 'Nothing captured.',
          textColor: Colors.black,



          fontSize: 18.00,
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: Colors.white,
          gravity: ToastGravity.CENTER);
      // AppGlobals.barcodestring = 'Nothing captured.';
      AppGlobals.barcodeerror = true;
    } catch (e) {
      Fluttertoast.showToast(
          msg: 'Unknown error: $e',
          textColor: Colors.black,
          fontSize: 18.00,
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: Colors.white,
          gravity: ToastGravity.CENTER);
      // AppGlobals.barcodestring = 'Unknown error: $e';
      AppGlobals.barcodeerror = true;
    }
  }

  static Future checkVersion(BuildContext context) async {
    await AppVersionUpdate.checkForUpdates(
      appleId: '6738003436',
      playStoreId: 'com.kassapos.maleva',
      // country: 'in',
    ).then((result) async {
      if (result.canUpdate!) {

        await AppVersionUpdate.showAlertUpdate(
          appVersionResult: result,
          context: context,
          backgroundColor: Colors.grey[200],
          title: 'New Update Available Now',
          titleTextStyle: GoogleFonts.lato(
            textStyle: const TextStyle(
              color: colour.commonColor,
              fontWeight: FontWeight.w600,
              fontSize: 24.0)),
          content: 'Would you like to update your app to the latest version?',
          contentTextStyle: GoogleFonts.lato(
      textStyle: const TextStyle(
            color: colour.commonColor,
            fontWeight: FontWeight.w400,
          )),
          updateButtonText: 'Update',
          cancelButtonText: 'Later',
          mandatory: true,
        );

        // // ## AppVersionUpdate.showBottomSheetUpdate ##
        // await AppVersionUpdate.showBottomSheetUpdate(
        //   context: context,
        //   mandatory: false,
        //   appVersionResult: result,
        //   content:   Text(
        //     'An update V ${result.storeVersion} is available would you like to update now ?',
        //   )
        //
        // );
        //
        // // ## AppVersionUpdate.showPageUpdate ##
        //
        // await AppVersionUpdate.showPageUpdate(
        //   context: context,
        //   mandatory: false,
        //   appVersionResult: result,
        // );
      }
    });
    // TODO: implement initState
  }

  static Future<String> uploadPdfOrImage(File file, int comid, int Id, String apiUploadPdfFile, String folderName, String subFolderName) async {
    try {
      return await ApiClient.uploadPdfOrFile(
        file,
        apiUploadPdfFile,
        comId: comid,
        id: Id,
        folderName: folderName,
        subFolderName: subFolderName,
      );
    } catch (_) {
      return "";
    }
  }

  static Future<String> upload(File imageFile, String imageapi, int Id, String FolderName, String SubFolderName) async {
    try {
      return await ApiClient.uploadImage(
        imageFile,
        imageapi,
        comId: AppGlobals.Comid,
        id: Id,
        folderName: FolderName,
        subFolderName: SubFolderName,
      );
    } catch (_) {
      return "";
    }
  }

  static Future launchInBrowser(String url) async {
    if (!await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    )) {
  throw Exception('Could not launch $url');
    }
  }

  static Future startDownloading(String urlpath) async {
    try {
      AppGlobals.downloadprogress = true;
      AppGlobals.progress = null;
  String filename = urlpath.split('/').last;
      // List<String> filelist =urlpath.split('/');
      // if(filelist.isNotEmpty){
      //   filename=filelist[filelist.length-1];
      //   filename =filelist.last;
      // }
      // else{
      //   filename=urlpath.split('/').last;
      // }
  final url = urlpath;

  final request = http.Request('GET', Uri.parse(url));
  final http.StreamedResponse response = await http.Client().send(request);

  final contentLength = response.contentLength;
      AppGlobals.progress = 0;
  List<int> bytes = [];

  final file = await _getFile(filename);
      response.stream.listen(
            (List<int> newBytes) {
          bytes.addAll(newBytes);
  final downloadedLength = bytes.length;
          AppGlobals.progress = downloadedLength / contentLength!;
        },
        onDone: () async {
          // var status1 = await Permission.manageExternalStorage.status;
          // if (!status1.isGranted) {
          //   await Permission.manageExternalStorage.request();
          // }
          AppGlobals.downloadprogress = false;
          AppGlobals.progress = 0;
          await file.writeAsBytes(bytes);
          // Share.shareFiles(file.path);
          Share.shareXFiles([XFile(file.path)], text: 'Maleva_Invoice.jpg');
          // final result = await  OpenFile.open(file.path);
          // print("type=${result.type}  message=${result.message}");
        },
        onError: (e) {
          AppGlobals.downloadprogress = false;
        },
        cancelOnError: true,
      );
    } on Error catch (_) {
      AppGlobals.downloadprogress = false;
    }
  }

  static Future<File> _getFile(String filename) async {
  final dir = await getApplicationDocumentsDirectory();
    return File("${dir.path}/$filename");
  }

}
