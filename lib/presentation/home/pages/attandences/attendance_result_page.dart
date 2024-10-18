import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_attendance/core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location/location.dart';
import '../../bloc/checkin_attendance/checkin_attendance_bloc.dart';
import '../../bloc/checkout_attendance/checkout_attendance_bloc.dart';
import '../attendance_success_page.dart';
import 'face_detector_checkin_page.dart';
import 'scanner_page.dart';

class AttendanceResultPage extends StatefulWidget {
  final bool isCheckin;
  final bool isMatch;
  final String attendanceType;
  const AttendanceResultPage({
    super.key,
    required this.isCheckin,
    required this.isMatch,
    required this.attendanceType,
  });

  @override
  State<AttendanceResultPage> createState() => _RecognitionResultPageState();
}

class _RecognitionResultPageState extends State<AttendanceResultPage> {
  double? latitude;
  double? longitude;

  @override
  void initState() {
    super.initState();
    getCurrentPosition();
  }

  Future<void> getCurrentPosition() async {
    try {
      Location location = Location();

      bool serviceEnabled;
      PermissionStatus permissionGranted;
      LocationData locationData;

      serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          return;
        }
      }

      permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          return;
        }
      }

      locationData = await location.getLocation();
      latitude = locationData.latitude;
      longitude = locationData.longitude;

      setState(() {});
    } on PlatformException catch (e) {
      if (e.code == 'IO_ERROR') {
        debugPrint(
            'A network error occurred trying to lookup the supplied coordinates: ${e.message}');
      } else {
        debugPrint('Failed to lookup coordinates: ${e.message}');
      }
    } catch (e) {
      debugPrint('An unknown error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Proses Presensi - ${widget.attendanceType == 'None' ? 'Manual' : widget.attendanceType}',
          style: const TextStyle(fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              widget.isMatch
                  ? Icons.check_circle_outline
                  : Icons.cancel_outlined,
              size: 120,
              color: widget.isMatch ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 24),
            Text(
              widget.isCheckin ? 'Checkin' : 'Checkout',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            if (widget.attendanceType == 'Face')
              Text(
                widget.isMatch ? 'Wajah Cocok' : 'Wajah Tidak Cocok',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: widget.isMatch ? Colors.green : Colors.red,
                ),
              )
            else if (widget.attendanceType == 'QR')
              Text(
                widget.isMatch ? 'QR Cocok' : 'QR Tidak Cocok',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: widget.isMatch ? Colors.green : Colors.red,
                ),
              ),
            const SizedBox(height: 24),
            if (widget.isCheckin && widget.isMatch)
              BlocConsumer<CheckinAttendanceBloc, CheckinAttendanceState>(
                listener: (context, state) {
                  state.maybeWhen(
                    orElse: () {},
                    error: (message) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(message)),
                      );
                    },
                    loaded: (responseModel) {
                      context.pushReplacement(const AttendanceSuccessPage(
                        status: 'Berhasil Checkin',
                      ));
                    },
                  );
                },
                builder: (context, state) {
                  return state.maybeWhen(
                    orElse: () {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: ElevatedButton(
                          onPressed: () {
                            context.read<CheckinAttendanceBloc>().add(
                                  CheckinAttendanceEvent.checkin(
                                      latitude.toString(),
                                      longitude.toString()),
                                );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: AppColors.primary, // Changed color
                          ),
                          child: const Text('Lanjutkan Checkin'),
                        ),
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
              )
            else if (!widget.isCheckin && widget.isMatch)
              BlocConsumer<CheckoutAttendanceBloc, CheckoutAttendanceState>(
                listener: (context, state) {
                  state.maybeWhen(
                    orElse: () {},
                    error: (message) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(message)),
                      );
                    },
                    loaded: (responseModel) {
                      context.pushReplacement(const AttendanceSuccessPage(
                        status: 'Berhasil Checkout',
                      ));
                    },
                  );
                },
                builder: (context, state) {
                  return state.maybeWhen(
                    orElse: () {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: ElevatedButton(
                          onPressed: () {
                            context.read<CheckoutAttendanceBloc>().add(
                                  CheckoutAttendanceEvent.checkout(
                                      latitude.toString(),
                                      longitude.toString()),
                                );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: AppColors.primary,
                          ),
                          child: const Text('Lanjutkan Checkout'),
                        ),
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
              ),
            const SizedBox(height: 16),
            if (widget.attendanceType == 'Face')
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FaceDetectorCheckinPage(
                        isCheckedIn: widget.isCheckin,
                      ),
                    ),
                  );
                },
                child: const Text('Ambil Wajah Lagi'),
              )
            else if (widget.attendanceType == 'QR')
              ElevatedButton(
                onPressed: () {
                  context.pushReplacement(
                      ScannerPage(isCheckin: widget.isCheckin));
                },
                child: const Text('Scan QR Code Lagi'),
              ),
          ],
        ),
      ),
    );
  }
}
