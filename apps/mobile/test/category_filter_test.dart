import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Category Filter Matching Logic Tests', () {
    final sampleServices = [
      {
        'id': '1',
        'name_mr': 'जय भवानी इलेक्ट्रिकल वर्क्स',
        'category': 'इलेक्ट्रिशियन',
        'desc': 'घरगुती व शेती पंपाचे वायरिंग.',
      },
      {
        'id': '2',
        'name_mr': 'महालक्ष्मी सुपर किराणा स्टोअर्स',
        'category': 'किराणा दुकान',
        'desc': 'सर्व प्रकारचा किराणा.',
      },
      {
        'id': '3',
        'name_mr': 'किसान ट्रॅक्टर सर्व्हिसेस',
        'category': 'ट्रॅक्टर भाड्याने',
        'desc': 'नांगरणी व रोटाव्हेटरसाठी ट्रॅक्टर.',
      },
      {
        'id': '4',
        'name_mr': 'धनवंतरी मेडिकल स्टोअर्स',
        'category': 'मेडिकल स्टोअर्स',
        'desc': 'औषधे व सिरप.',
      },
      {
        'id': '5',
        'name_mr': 'साई प्लंबिंग सर्व्हिसेस',
        'category': 'प्लंबर व पाणी फिटिंग',
        'desc': 'पाईपलाईन लीकेज दुरुस्ती.',
      },
      {
        'id': '6',
        'name_mr': 'नरडाणा ऑटो रिक्षा',
        'category': 'ऑटो रिक्षा व वाहतूक',
        'desc': '२४ तास ऑटो सेवा.',
      },
    ];

    bool matchesCategory(Map<String, dynamic> item, String targetCat) {
      final t = targetCat.trim().toLowerCase();
      final cat = (item['category'] ?? '').toString().toLowerCase();
      final name = (item['name_mr'] ?? '').toString().toLowerCase();
      final desc = (item['desc'] ?? '').toString().toLowerCase();

      if (t.contains('इलेक्ट्रिशियन') || t.contains('इलेक्ट्रिक')) {
        return cat.contains('इलेक्ट्रिशियन') ||
            cat.contains('इलेक्ट्रिक') ||
            desc.contains('वायरिंग') ||
            name.contains('इलेक्ट्रिक');
      }
      if (t.contains('प्लंबर') || t.contains('नळ')) {
        return cat.contains('प्लंबर') ||
            cat.contains('फिटिंग') ||
            desc.contains('प्लंबिंग') ||
            desc.contains('नळ');
      }
      if (t.contains('किराणा') || t.contains('ग्रॉसरी')) {
        return cat.contains('किराणा') || cat.contains('सुपर') || name.contains('किराणा');
      }
      if (t.contains('मेडिकल') || t.contains('औषध')) {
        return cat.contains('मेडिकल') ||
            cat.contains('औषध') ||
            cat.contains('फार्मसी') ||
            desc.contains('औषधे');
      }
      if (t.contains('ट्रॅक्टर') || t.contains('शेती अवजारे')) {
        return cat.contains('ट्रॅक्टर') || cat.contains('अवजारे') || desc.contains('ट्रॅक्टर');
      }
      if (t.contains('ऑटो') || t.contains('टॅक्सी') || t.contains('रिक्षा')) {
        return cat.contains('ऑटो') ||
            cat.contains('टॅक्सी') ||
            cat.contains('रिक्षा') ||
            cat.contains('वाहतूक');
      }

      return cat.contains(t) || name.contains(t) || t.contains(cat);
    }

    test('Clicking "इलेक्ट्रिशियन" only matches electrical businesses', () {
      final results = sampleServices.where((s) => matchesCategory(s, 'इलेक्ट्रिशियन')).toList();
      expect(results.length, 1);
      expect(results.first['name_mr'], 'जय भवानी इलेक्ट्रिकल वर्क्स');
    });

    test('Clicking "किराणा" only matches grocery stores', () {
      final results = sampleServices.where((s) => matchesCategory(s, 'किराणा')).toList();
      expect(results.length, 1);
      expect(results.first['name_mr'], 'महालक्ष्मी सुपर किराणा स्टोअर्स');
    });

    test('Clicking "प्लंबर" only matches plumbing businesses', () {
      final results = sampleServices.where((s) => matchesCategory(s, 'प्लंबर')).toList();
      expect(results.length, 1);
      expect(results.first['name_mr'], 'साई प्लंबिंग सर्व्हिसेस');
    });

    test('Clicking "मेडिकल" only matches medical stores', () {
      final results = sampleServices.where((s) => matchesCategory(s, 'मेडिकल')).toList();
      expect(results.length, 1);
      expect(results.first['name_mr'], 'धनवंतरी मेडिकल स्टोअर्स');
    });

    test('Clicking "ट्रॅक्टर भाड्याने" only matches tractor services', () {
      final results = sampleServices.where((s) => matchesCategory(s, 'ट्रॅक्टर भाड्याने')).toList();
      expect(results.length, 1);
      expect(results.first['name_mr'], 'किसान ट्रॅक्टर सर्व्हिसेस');
    });

    test('Clicking "ऑटो / टॅक्सी" only matches auto rickshaw services', () {
      final results = sampleServices.where((s) => matchesCategory(s, 'ऑटो / टॅक्सी')).toList();
      expect(results.length, 1);
      expect(results.first['name_mr'], 'नरडाणा ऑटो रिक्षा');
    });
  });
}

