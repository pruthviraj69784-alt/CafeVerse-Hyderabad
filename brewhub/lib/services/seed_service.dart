import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/cafe_model.dart';
import '../models/product_model.dart';

class SeedService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> seedDatabaseIfEmpty() async {
    try {
      final cafeQuery = await _firestore.collection('cafes').limit(1).get();
      if (cafeQuery.docs.isNotEmpty) {
        debugPrint('Database already has cafes, skipping seeding.');
        return;
      }

      debugPrint('Database is empty. Starting seeding Hyderabad cafes...');

      final cafesData = [
        {
          'name': 'Roastery Coffee House',
          'area': 'Banjara Hills',
          'imageUrl': 'https://images.unsplash.com/photo-1554118811-1e0d58224f24?auto=format&fit=crop&w=600&q=80',
          'rating': 4.8,
          'costForTwo': 1200,
          'description': 'A beautiful garden cafe known for its artisanal house-roasted coffee, signature cold brews, and classic continental dishes in a serene heritage bungalow.',
          'latitude': 17.4173,
          'longitude': 78.4485,
          'photoUrls': [
            'https://images.unsplash.com/photo-1554118811-1e0d58224f24?auto=format&fit=crop&w=600&q=80',
            'https://images.unsplash.com/photo-1498804103079-a6351b050096?auto=format&fit=crop&w=600&q=80',
            'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=600&q=80'
          ],
          'ambianceTags': ['Outdoor Seating', 'Greenery', 'Study Friendly'],
          'menu': [
            {'name': 'Cold Brew Coffee', 'price': 240.0, 'category': 'Beverages', 'description': 'Slow-steeped for 18 hours, smooth and low-acid.'},
            {'name': 'Cappuccino', 'price': 180.0, 'category': 'Beverages', 'description': 'Rich espresso with steamed milk and thick foam.'},
            {'name': 'Roastery Special Burger', 'price': 380.0, 'category': 'Food', 'description': 'Juicy chicken patty with homemade sauce and fries.'},
          ]
        },
        {
          'name': 'Theory Cafe',
          'area': 'Jubilee Hills',
          'imageUrl': 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?auto=format&fit=crop&w=600&q=80',
          'rating': 4.6,
          'costForTwo': 900,
          'description': 'A modern minimalist hangout space featuring top-tier single-origin coffees, clean aesthetic decor, and a quiet ambiance perfect for remote work or reading.',
          'latitude': 17.4332,
          'longitude': 78.4068,
          'photoUrls': [
            'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?auto=format&fit=crop&w=600&q=80',
            'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?auto=format&fit=crop&w=600&q=80',
            'https://images.unsplash.com/photo-1445116572660-236099ec97a0?auto=format&fit=crop&w=600&q=80'
          ],
          'ambianceTags': ['Work Friendly', 'Aesthetic', 'Modern'],
          'menu': [
            {'name': 'Flat White', 'price': 190.0, 'category': 'Beverages', 'description': 'Double shot espresso with microfoam.'},
            {'name': 'Avocado Toast', 'price': 320.0, 'category': 'Food', 'description': 'Smashed avocado, cherry tomatoes, and feta on sourdough.'},
            {'name': 'Blueberry Cheesecake', 'price': 220.0, 'category': 'Desserts', 'description': 'Creamy New York style cheesecake with blueberry compote.'},
          ]
        },
        {
          'name': 'Autumn Leaf Cafe',
          'area': 'Jubilee Hills',
          'imageUrl': 'https://images.unsplash.com/photo-1521017432531-fbd92d768814?auto=format&fit=crop&w=600&q=80',
          'rating': 4.5,
          'costForTwo': 800,
          'description': 'A lovely pet-friendly garden cafe with a rustic layout, boutique shop, and comforting breakfast items that make you feel right at home.',
          'latitude': 17.4285,
          'longitude': 78.4112,
          'photoUrls': [
            'https://images.unsplash.com/photo-1521017432531-fbd92d768814?auto=format&fit=crop&w=600&q=80',
            'https://images.unsplash.com/photo-1508700115892-45ecd05ae2ad?auto=format&fit=crop&w=600&q=80'
          ],
          'ambianceTags': ['Date Friendly', 'Vintage', 'Pet Friendly'],
          'menu': [
            {'name': 'English Breakfast Platter', 'price': 420.0, 'category': 'Food', 'description': 'Eggs, chicken sausages, baked beans, toast, and grilled tomato.'},
            {'name': 'Cafe Latte', 'price': 170.0, 'category': 'Beverages', 'description': 'Espresso with steamed milk and light foam.'},
            {'name': 'Waffles with Maple Syrup', 'price': 250.0, 'category': 'Desserts', 'description': 'Warm Belgian waffles served with maple syrup and whipped cream.'},
          ]
        },
        {
          'name': 'Concu',
          'area': 'Jubilee Hills',
          'imageUrl': 'https://images.unsplash.com/photo-1559925393-8be0ec4767c8?auto=format&fit=crop&w=600&q=80',
          'rating': 4.7,
          'costForTwo': 1000,
          'description': 'Premium European style patisserie offering exquisite pastries, designer cakes, artisan coffees, and high tea items in an elegant courtyard setting.',
          'latitude': 17.4258,
          'longitude': 78.4095,
          'photoUrls': [
            'https://images.unsplash.com/photo-1559925393-8be0ec4767c8?auto=format&fit=crop&w=600&q=80',
            'https://images.unsplash.com/photo-1563729784474-d77dbb933a9e?auto=format&fit=crop&w=600&q=80'
          ],
          'ambianceTags': ['Luxury', 'Dessert Haven', 'Quiet'],
          'menu': [
            {'name': 'Macaron Box of 3', 'price': 270.0, 'category': 'Desserts', 'description': 'Assorted classic French macarons.'},
            {'name': 'Cappuccino', 'price': 190.0, 'category': 'Beverages', 'description': 'Smooth espresso with dense frothed milk.'},
            {'name': 'Croissant Sandwich', 'price': 340.0, 'category': 'Food', 'description': 'Butter croissant filled with cheese and fresh greens.'},
          ]
        },
        {
          'name': 'Last House Coffee',
          'area': 'Banjara Hills',
          'imageUrl': 'https://images.unsplash.com/photo-1445116572660-236099ec97a0?auto=format&fit=crop&w=600&q=80',
          'rating': 4.4,
          'costForTwo': 500,
          'description': 'A cozy, minimalist coffee shop looking over a lakeside view. Known for pour-overs, quick bites, and a highly study-friendly environment.',
          'latitude': 17.4201,
          'longitude': 78.4412,
          'photoUrls': [
            'https://images.unsplash.com/photo-1445116572660-236099ec97a0?auto=format&fit=crop&w=600&q=80',
            'https://images.unsplash.com/photo-1506619210096-73c5d6af7303?auto=format&fit=crop&w=600&q=80'
          ],
          'ambianceTags': ['Study Friendly', 'Minimalist', 'Cozy'],
          'menu': [
            {'name': 'Americano', 'price': 140.0, 'category': 'Beverages', 'description': 'Rich espresso diluted with hot water.'},
            {'name': 'Pour Over Coffee', 'price': 180.0, 'category': 'Beverages', 'description': 'Hand-poured single origin specialty coffee.'},
            {'name': 'Paneer Tikka Sandwich', 'price': 220.0, 'category': 'Food', 'description': 'Spiced paneer filling between grilled bread slices.'},
          ]
        },
        {
          'name': 'Ironhill Cafe',
          'area': 'Madhapur',
          'imageUrl': 'https://images.unsplash.com/photo-1507133750040-4a8f57021571?auto=format&fit=crop&w=600&q=80',
          'rating': 4.5,
          'costForTwo': 1100,
          'description': 'A very spacious, multi-level cafe in the heart of Hitech City. Features multi-cuisine food options, strong Wi-Fi, and open workspaces.',
          'latitude': 17.4485,
          'longitude': 78.3847,
          'photoUrls': [
            'https://images.unsplash.com/photo-1507133750040-4a8f57021571?auto=format&fit=crop&w=600&q=80',
            'https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=600&q=80'
          ],
          'ambianceTags': ['Work Friendly', 'Spacious', 'Modern'],
          'menu': [
            {'name': 'Cappuccino', 'price': 170.0, 'category': 'Beverages', 'description': 'Hot classic cappuccino brew.'},
            {'name': 'Alfredo Pasta Chicken', 'price': 360.0, 'category': 'Food', 'description': 'Penne in rich creamy white sauce with grilled chicken.'},
            {'name': 'Fries Basket', 'price': 180.0, 'category': 'Food', 'description': 'Crispy golden fries served with ketchup and mayo.'},
          ]
        },
        {
          'name': 'Heart Cup Coffee',
          'area': 'Gachibowli',
          'imageUrl': 'https://images.unsplash.com/photo-1511920170033-f8396924c348?auto=format&fit=crop&w=600&q=80',
          'rating': 4.3,
          'costForTwo': 1400,
          'description': 'A sprawling open-air bar and cafe famous for live music events, karaoke nights, cold beers, and a high-energy social atmosphere.',
          'latitude': 17.4411,
          'longitude': 78.3478,
          'photoUrls': [
            'https://images.unsplash.com/photo-1511920170033-f8396924c348?auto=format&fit=crop&w=600&q=80',
            'https://images.unsplash.com/photo-1485182708500-e8f1f318ba72?auto=format&fit=crop&w=600&q=80'
          ],
          'ambianceTags': ['Lively', 'Live Music', 'Social Hangout'],
          'menu': [
            {'name': 'Cold Coffee with Ice Cream', 'price': 220.0, 'category': 'Beverages', 'description': 'Rich blended cold coffee topped with vanilla scoop.'},
            {'name': 'Margherita Pizza 10 inch', 'price': 350.0, 'category': 'Food', 'description': 'Classic mozzarella and tomato sauce pizza.'},
            {'name': 'Loaded Nachos', 'price': 280.0, 'category': 'Food', 'description': 'Corn chips baked with cheese, salsa, and jalapenos.'},
          ]
        },
        {
          'name': 'True Black Coffee',
          'area': 'Jubilee Hills',
          'imageUrl': 'https://images.unsplash.com/photo-1506619210096-73c5d6af7303?auto=format&fit=crop&w=600&q=80',
          'rating': 4.7,
          'costForTwo': 1100,
          'description': 'Specialty coffee roastery designed for true coffee connoisseurs. Minimalist concrete interiors, serene ambient lighting, and top-tier brews.',
          'latitude': 17.4320,
          'longitude': 78.4042,
          'photoUrls': [
            'https://images.unsplash.com/photo-1506619210096-73c5d6af7303?auto=format&fit=crop&w=600&q=80',
            'https://images.unsplash.com/photo-1509042239860-f550ce710b93?auto=format&fit=crop&w=600&q=80'
          ],
          'ambianceTags': ['Minimalist', 'Work Friendly', 'Specialty Brews'],
          'menu': [
            {'name': 'Pour Over V60', 'price': 200.0, 'category': 'Beverages', 'description': 'Precision hand-brewed specialty light roast.'},
            {'name': 'Cortado', 'price': 160.0, 'category': 'Beverages', 'description': 'Equal parts espresso and warm textured milk.'},
            {'name': 'Almond Croissant', 'price': 260.0, 'category': 'Desserts', 'description': 'Flaky twice-baked butter croissant with almond frangipane.'},
          ]
        },
        {
          'name': 'Huber & Holly',
          'area': 'Banjara Hills',
          'imageUrl': 'https://images.unsplash.com/photo-1563729784474-d77dbb933a9e?auto=format&fit=crop&w=600&q=80',
          'rating': 4.6,
          'costForTwo': 850,
          'description': 'A premium ice cream cafe offering fresh-churned gourmet ice creams, customized ice cream cakes, and loaded pizzas in a chic modern environment.',
          'latitude': 17.4190,
          'longitude': 78.4452,
          'photoUrls': [
            'https://images.unsplash.com/photo-1563729784474-d77dbb933a9e?auto=format&fit=crop&w=600&q=80',
            'https://images.unsplash.com/photo-1476887334197-56adcd2c602a?auto=format&fit=crop&w=600&q=80'
          ],
          'ambianceTags': ['Date Friendly', 'Desserts', 'Premium'],
          'menu': [
            {'name': 'Mighty Midas Cone', 'price': 450.0, 'category': 'Desserts', 'description': 'Premium golden cone with 16 elements and 24K edible gold.'},
            {'name': 'Pesto & Sun-Dried Tomato Pizza', 'price': 390.0, 'category': 'Food', 'description': 'Thin crust sourdough pizza with pesto and sun-dried tomatoes.'},
            {'name': 'Hot Chocolate', 'price': 210.0, 'category': 'Beverages', 'description': 'Thick Italian style hot chocolate.'},
          ]
        },
        {
          'name': 'The Hole in the Wall Cafe',
          'area': 'Jubilee Hills',
          'imageUrl': 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?auto=format&fit=crop&w=600&q=80',
          'rating': 4.4,
          'costForTwo': 450,
          'description': 'A quirky, fun board game cafe loaded with books, comfortable seating, all-day waffles, and comfort foods at very student-friendly prices.',
          'latitude': 17.4355,
          'longitude': 78.4118,
          'photoUrls': [
            'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?auto=format&fit=crop&w=600&q=80',
            'https://images.unsplash.com/photo-1554118811-1e0d58224f24?auto=format&fit=crop&w=600&q=80'
          ],
          'ambianceTags': ['Games & Books', 'Cozy', 'Student Hub'],
          'menu': [
            {'name': 'Waffles with Nutella', 'price': 200.0, 'category': 'Desserts', 'description': 'Belgian waffles smothered in hot Nutella spread.'},
            {'name': 'Masala Chai Kettle', 'price': 120.0, 'category': 'Beverages', 'description': 'Ginger cardamon spiced Indian tea serves two.'},
            {'name': 'Maggi Loaded with Veggies', 'price': 110.0, 'category': 'Food', 'description': 'Spiced instant noodles cooked with mix vegetables.'},
          ]
        }
      ];

      for (var cafe in cafesData) {
        // Create Cafe Model parameters
        final cafeDoc = _firestore.collection('cafes').doc();
        
        final newCafe = CafeModel(
          id: cafeDoc.id,
          name: cafe['name'] as String,
          area: cafe['area'] as String,
          imageUrl: cafe['imageUrl'] as String,
          rating: (cafe['rating'] as num).toDouble(),
          costForTwo: cafe['costForTwo'] as int,
          description: cafe['description'] as String,
          latitude: (cafe['latitude'] as num).toDouble(),
          longitude: (cafe['longitude'] as num).toDouble(),
          photoUrls: List<String>.from(cafe['photoUrls'] as List),
          ambianceTags: List<String>.from(cafe['ambianceTags'] as List),
        );

        await cafeDoc.set(newCafe.toMap());
        debugPrint('Created Cafe: ${newCafe.name}');

        // Seed 6 tables under cafes/{cafeId}/tables
        final tables = [
          {'tableNumber': 1, 'capacity': 2},
          {'tableNumber': 2, 'capacity': 2},
          {'tableNumber': 3, 'capacity': 4},
          {'tableNumber': 4, 'capacity': 4},
          {'tableNumber': 5, 'capacity': 6},
          {'tableNumber': 6, 'capacity': 8},
        ];
        for (var t in tables) {
          final tableDoc = cafeDoc.collection('tables').doc();
          await tableDoc.set({
            'tableNumber': t['tableNumber'],
            'capacity': t['capacity'],
            'isActive': true,
          });
        }
        debugPrint('Seeded 6 tables for ${newCafe.name}');

        // Seed products under /products
        final menu = cafe['menu'] as List<Map<String, dynamic>>;
        for (var item in menu) {
          final productDoc = _firestore.collection('products').doc();
          final newProduct = ProductModel(
            id: productDoc.id,
            name: item['name'] as String,
            price: (item['price'] as num).toDouble(),
            category: item['category'] as String,
            description: item['description'] as String,
            imageUrl: 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?auto=format&fit=crop&w=600&q=80', // default item image
            rating: 4.5,
            reviewCount: 15,
            available: true,
            createdAt: DateTime.now(),
            cafeId: cafeDoc.id,
          );
          await productDoc.set(newProduct.toMap());
        }
        debugPrint('Seeded ${menu.length} items for ${newCafe.name}');

        // Seed 2 reviews per cafe
        final mockReviews = [
          {
            'userName': 'Ananya Rao',
            'rating': 4.5,
            'comment': 'Really loved the ambiance here! Perfect spot for working or deep conversations. The service was excellent.',
          },
          {
            'userName': 'Karthik S.',
            'rating': 5.0,
            'comment': 'Absolutely outstanding coffee and the staff is very polite. Easily one of the top cafes in the area.',
          }
        ];
        for (var rev in mockReviews) {
          final reviewDoc = _firestore.collection('reviews').doc();
          await reviewDoc.set({
            'cafeId': cafeDoc.id,
            'userId': 'user_mock_${rev['userName'].toString().split(' ').first.toLowerCase()}',
            'userName': rev['userName'],
            'rating': rev['rating'],
            'comment': rev['comment'],
            'createdAt': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
          });
        }
        debugPrint('Seeded reviews for ${newCafe.name}');
      }
      debugPrint('Seeding completed successfully!');
    } catch (e) {
      debugPrint('Error during database seeding: $e');
    }
  }
}
