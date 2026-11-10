import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nardana_connect/core/constants/app_colors.dart';
import 'package:nardana_connect/core/navigation/app_back_scope.dart';
import 'package:nardana_connect/core/navigation/back_button_handler.dart';

class PdfViewerScreen extends StatelessWidget {
  final String title;
  final String? url;
  final String? fallbackRoute;

  const PdfViewerScreen({
    super.key,
    required this.title,
    this.url,
    this.fallbackRoute = '/notices',
  });

  @override
  Widget build(BuildContext context) {
    return AppBackScope(
      fallbackRoute: fallbackRoute ?? '/notices',
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          title: Text(
            title.isNotEmpty ? title : 'दस्तऐवज (Document)',
            style: GoogleFonts.mukta(fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => BackButtonHandler.safePop(context, fallbackRoute: fallbackRoute ?? '/notices'),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.share_rounded, color: Colors.white),
              tooltip: 'दस्तऐवज शेअर करा',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('दस्तऐवज लिंक कॉपी केली आहे.', style: GoogleFonts.mukta()),
                    backgroundColor: AppColors.primaryBlue,
                  ),
                );
              },
            ),
          ],
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.picture_as_pdf_rounded, color: Colors.red.shade700, size: 48),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.mukta(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'अधिकृत ग्रामपंचायत नरडाणा दस्तऐवज (PDF)',
                      style: GoogleFonts.mukta(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.check_circle_outline_rounded, color: AppColors.secondaryGreen, size: 28),
                          const SizedBox(height: 8),
                          Text(
                            'दस्तऐवज डिजिटल स्वरूपात सुरक्षितपणे उपलब्ध आहे.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.mukta(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          if (url != null && url!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              url!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.mukta(fontSize: 11, color: AppColors.textMuted),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('दस्तऐवज डाऊनलोड प्रक्रिया सुरू झाली...', style: GoogleFonts.mukta()),
                            backgroundColor: AppColors.secondaryGreen,
                          ),
                        );
                      },
                      icon: const Icon(Icons.download_rounded, size: 20),
                      label: Text('PDF डाऊनलोड करा', style: GoogleFonts.mukta(fontSize: 15, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

