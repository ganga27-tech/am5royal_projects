import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/product.dart';

part 'product_model.freezed.dart';
part 'product_model.g.dart';

@freezed
class ProductModel with _$ProductModel {
  const ProductModel._(); // Allows adding methods/getters

  const factory ProductModel({
    required String id,
    required String name,
    required String description,
    required double price,
    required int stock,
    required String imageUrl,
    required String category,
  }) = _ProductModel;

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);

  // Maps this data model to a pure domain entity
  Product toEntity() {
    return Product(
      id: id,
      name: name,
      description: description,
      price: price,
      stock: stock,
      imageUrl: imageUrl,
      category: category,
    );
  }

  // Creates a data model from a domain entity
  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      name: product.name,
      description: product.description,
      price: product.price,
      stock: product.stock,
      imageUrl: product.imageUrl,
      category: product.category,
    );
  }

  // Static list of categories represented as enriched CategoryItem instances
  static const List<CategoryItem> categories = [
    CategoryItem(
      number: '01',
      title: 'Training & Education',
      icon: Icons.school_rounded,
      color: Color(0xFF1E88E5),
      id: 'prod_01',
      name: 'Flutter & Dart Advanced Masterclass',
      description: 'Comprehensive course covering clean architecture, state management, and custom widgets in Flutter.',
      price: 299.99,
      stock: 50,
      imageUrl: 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=500&auto=format&fit=crop&q=60',
      category: 'Training & Education',
    ),
    CategoryItem(
      number: '02',
      title: 'Event & Wedding',
      icon: Icons.favorite_rounded,
      color: Color(0xFFD81B60),
      id: 'prod_02',
      name: 'Royal Wedding Photography Package',
      description: 'Full-day wedding photography coverage by award-winning photographers, including high-res digital files.',
      price: 1499.00,
      stock: 10,
      imageUrl: 'https://images.unsplash.com/photo-1537907690979-ee8e01276184?w=500&auto=format&fit=crop&q=60',
      category: 'Event & Wedding',
    ),
    CategoryItem(
      number: '03',
      title: 'Healthcare & Medical',
      icon: Icons.medical_services_rounded,
      color: Color(0xFFE53935),
      id: 'prod_03',
      name: 'Premium Quality N95 Face Masks',
      description: 'Pack of 50 high-filtration protective N95 face masks with adjustable nose clip.',
      price: 25.50,
      stock: 200,
      imageUrl: 'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=500&auto=format&fit=crop&q=60',
      category: 'Healthcare & Medical',
    ),
    CategoryItem(
      number: '04',
      title: 'Accommodation',
      icon: Icons.hotel_rounded,
      color: Color(0xFF00ACC1),
      id: 'prod_04',
      name: 'Luxury Suite 1-Night Stay',
      description: 'Premium suite booking with king-size bed, city view, and complimentary breakfast at Royal Palms.',
      price: 180.00,
      stock: 15,
      imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=500&auto=format&fit=crop&q=60',
      category: 'Accommodation',
    ),
    CategoryItem(
      number: '05',
      title: 'Real Estate',
      icon: Icons.home_rounded,
      color: Color(0xFF43A047),
      id: 'prod_05',
      name: 'Commercial Office Space Lease',
      description: 'Modern fully furnished office space in downtown business center with high-speed internet access.',
      price: 1200.00,
      stock: 5,
      imageUrl: 'https://images.unsplash.com/photo-1497366216548-37526070297c?w=500&auto=format&fit=crop&q=60',
      category: 'Real Estate',
    ),
    CategoryItem(
      number: '06',
      title: 'Legal',
      icon: Icons.gavel_rounded,
      color: Color(0xFF3949AB),
      id: 'prod_06',
      name: 'Comprehensive Business Agreement Draft',
      description: 'Professional legal template for standard commercial agreements, drafted by corporate law experts.',
      price: 75.00,
      stock: 100,
      imageUrl: 'https://images.unsplash.com/photo-1450133064473-71024230f91b?w=500&auto=format&fit=crop&q=60',
      category: 'Legal',
    ),
    CategoryItem(
      number: '07',
      title: 'Lifestyle & Wellness',
      icon: Icons.self_improvement_rounded,
      color: Color(0xFF00897B),
      id: 'prod_07',
      name: 'Organic Herbal Tea Assortment',
      description: 'Gift box containing 6 diverse flavors of loose-leaf organic herbal teas for wellness.',
      price: 24.99,
      stock: 150,
      imageUrl: 'https://images.unsplash.com/photo-1576092768241-dec231879fc3?w=500&auto=format&fit=crop&q=60',
      category: 'Lifestyle & Wellness',
    ),
    CategoryItem(
      number: '08',
      title: 'Freelancers & Jobs',
      icon: Icons.laptop_mac_rounded,
      color: Color(0xFFFFB300),
      id: 'prod_08',
      name: 'Professional CV Writing Service',
      description: 'Get your resume written and optimized by recruiting industry specialists to land your dream job.',
      price: 85.00,
      stock: 30,
      imageUrl: 'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=500&auto=format&fit=crop&q=60',
      category: 'Freelancers & Jobs',
    ),
    CategoryItem(
      number: '09',
      title: 'Job',
      icon: Icons.assignment_ind_rounded,
      color: Color(0xFFF4511E),
      id: 'prod_09',
      name: 'Corporate Recruitment Placement Consultation',
      description: 'Find top talent or land your next career opportunity with our customized placement services.',
      price: 150.00,
      stock: 200,
      imageUrl: 'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=500&auto=format&fit=crop&q=60',
      category: 'Job',
    ),
    CategoryItem(
      number: '10',
      title: 'Jobs & Recruitment',
      icon: Icons.badge_rounded,
      color: Color(0xFF039BE5),
      id: 'prod_10',
      name: 'Enterprise Job Board Posting Credit',
      description: 'Post and promote your job openings on our exclusive high-traffic network for maximum reach.',
      price: 49.99,
      stock: 500,
      imageUrl: 'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=500&auto=format&fit=crop&q=60',
      category: 'Jobs & Recruitment',
    ),
    CategoryItem(
      number: '11',
      title: 'Healthcare & Hospitals',
      icon: Icons.local_hospital_rounded,
      color: Color(0xFFE53935),
      id: 'prod_11',
      name: 'Full Body Health Checkup Voucher',
      description: 'Comprehensive screening voucher covering blood work, ECG, and general physical assessment.',
      price: 99.00,
      stock: 100,
      imageUrl: 'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=500&auto=format&fit=crop&q=60',
      category: 'Healthcare & Hospitals',
    ),
    CategoryItem(
      number: '12',
      title: 'Medical Equipment & Emergency Support',
      icon: Icons.emergency_rounded,
      color: Color(0xFFD81B60),
      id: 'prod_12',
      name: 'Automated External Defibrillator (AED)',
      description: 'Easy-to-use portable AED with clear voice instructions for corporate office safety compliance.',
      price: 1250.00,
      stock: 8,
      imageUrl: 'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=500&auto=format&fit=crop&q=60',
      category: 'Medical Equipment & Emergency Support',
    ),
    CategoryItem(
      number: '13',
      title: 'Used Vehicles',
      icon: Icons.directions_car_rounded,
      color: Color(0xFF1E88E5),
      id: 'prod_13',
      name: 'Certified Pre-Owned SUV',
      description: 'Fully inspected pre-owned compact SUV with 4-wheel drive and full service record history.',
      price: 24500.00,
      stock: 2,
      imageUrl: 'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=500&auto=format&fit=crop&q=60',
      category: 'Used Vehicles',
    ),
    CategoryItem(
      number: '14',
      title: 'Food & Beverage',
      icon: Icons.fastfood_rounded,
      color: Color(0xFFF4511E),
      id: 'prod_14',
      name: 'Roasted Single-Origin Arabica Coffee',
      description: '1kg bag of premium quality medium-dark roasted whole bean coffee with notes of dark chocolate.',
      price: 28.50,
      stock: 120,
      imageUrl: 'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=500&auto=format&fit=crop&q=60',
      category: 'Food & Beverage',
    ),
    CategoryItem(
      number: '15',
      title: 'Travel & Tourism',
      icon: Icons.flight_takeoff_rounded,
      color: Color(0xFF00ACC1),
      id: 'prod_15',
      name: '3-Day Goa Tour Package',
      description: 'All-inclusive weekend getaway featuring beach resort stay, dining vouchers, and guided sightseeing.',
      price: 350.00,
      stock: 12,
      imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=500&auto=format&fit=crop&q=60',
      category: 'Travel & Tourism',
    ),
    CategoryItem(
      number: '16',
      title: 'Shopping & Retail',
      icon: Icons.shopping_bag_rounded,
      color: Color(0xFFE91E63),
      id: 'prod_16',
      name: 'Handcrafted Italian Leather Handbag',
      description: 'Elegant structured handbag made of vegetable-tanned genuine leather with brass hardware.',
      price: 189.00,
      stock: 25,
      imageUrl: 'https://images.unsplash.com/photo-1544816155-12df9643f363?w=500&auto=format&fit=crop&q=60',
      category: 'Shopping & Retail',
    ),
    CategoryItem(
      number: '17',
      title: 'Electronics & Appliances',
      icon: Icons.devices_rounded,
      color: Color(0xFF8E24AA),
      id: 'prod_17',
      name: 'Ultra HD Smart OLED TV 55"',
      description: 'Stunning 4K resolution television with HDR10 support, dolby atmos sound, and smart OS integration.',
      price: 799.99,
      stock: 18,
      imageUrl: 'https://images.unsplash.com/photo-1593305841991-05c297ba4575?w=500&auto=format&fit=crop&q=60',
      category: 'Electronics & Appliances',
    ),
    CategoryItem(
      number: '18',
      title: 'Furniture & Home',
      icon: Icons.chair_rounded,
      color: Color(0xFF6D4C41),
      id: 'prod_18',
      name: 'Ergonomic Memory Foam Office Chair',
      description: 'Fully adjustable task chair with high-density foam seat, mesh backrest, and 3D dynamic armrests.',
      price: 219.00,
      stock: 45,
      imageUrl: 'https://images.unsplash.com/photo-1505797149-43b0069ec26b?w=500&auto=format&fit=crop&q=60',
      category: 'Furniture & Home',
    ),
    CategoryItem(
      number: '19',
      title: 'Finance',
      icon: Icons.monetization_on_rounded,
      color: Color(0xFF43A047),
      id: 'prod_19',
      name: 'Premium Wealth Management Consultation',
      description: 'Private 1-on-1 strategy session with a certified financial planner to optimize your assets.',
      price: 150.00,
      stock: 80,
      imageUrl: 'https://images.unsplash.com/photo-1450133064473-71024230f91b?w=500&auto=format&fit=crop&q=60',
      category: 'Finance',
    ),
    CategoryItem(
      number: '20',
      title: 'Building Construction Material & Equipment',
      icon: Icons.construction_rounded,
      color: Color(0xFFF4511E),
      id: 'prod_20',
      name: 'Premium Portland Cement Bag (50kg)',
      description: 'High-strength structural grade portland cement suitable for residential foundation and masonry.',
      price: 8.50,
      stock: 1000,
      imageUrl: 'https://images.unsplash.com/photo-1497366216548-37526070297c?w=500&auto=format&fit=crop&q=60',
      category: 'Building Construction Material & Equipment',
    ),
    CategoryItem(
      number: '21',
      title: 'Electronics & Electrical Goods & Supplies',
      icon: Icons.electric_bolt_rounded,
      color: Color(0xFFFFB300),
      id: 'prod_21',
      name: 'High-Conductivity Copper Wire Reel (100m)',
      description: 'Heavy duty insulated copper wire coil optimized for household electrical circuits and outlets.',
      price: 45.00,
      stock: 150,
      imageUrl: 'https://images.unsplash.com/photo-1593305841991-05c297ba4575?w=500&auto=format&fit=crop&q=60',
      category: 'Electronics & Electrical Goods & Supplies',
    ),
    CategoryItem(
      number: '22',
      title: 'Medical Equipment & Devices',
      icon: Icons.biotech_rounded,
      color: Color(0xFF546E7A),
      id: 'prod_22',
      name: 'Portable Digital Blood Pressure Monitor',
      description: 'Clinically validated automatic upper-arm blood pressure monitor with digital display and memory.',
      price: 39.99,
      stock: 90,
      imageUrl: 'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=500&auto=format&fit=crop&q=60',
      category: 'Medical Equipment & Devices',
    ),
    CategoryItem(
      number: '23',
      title: 'Industrial Plants, Machinery & Equipment',
      icon: Icons.precision_manufacturing_rounded,
      color: Color(0xFF757575),
      id: 'prod_23',
      name: 'Heavy-Duty CNC Milling Machine Parts',
      description: 'Replacement parts kit containing high-durability alloy components for production machinery.',
      price: 380.00,
      stock: 15,
      imageUrl: 'https://images.unsplash.com/photo-1497366216548-37526070297c?w=500&auto=format&fit=crop&q=60',
      category: 'Industrial Plants, Machinery & Equipment',
    ),
    CategoryItem(
      number: '24',
      title: 'Food, Agriculture & Farming',
      icon: Icons.agriculture_rounded,
      color: Color(0xFF7CB342),
      id: 'prod_24',
      name: 'Organic Liquid Fertilizer (5L)',
      description: 'Highly concentrated nutrient-rich plant food designed to maximize crop yield and soil health.',
      price: 22.00,
      stock: 300,
      imageUrl: 'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=500&auto=format&fit=crop&q=60',
      category: 'Food, Agriculture & Farming',
    ),
    CategoryItem(
      number: '25',
      title: 'Food Products',
      icon: Icons.dining_rounded,
      color: Color(0xFFE53935),
      id: 'prod_25',
      name: 'Hand-Churned Pure A2 Cow Ghee',
      description: '100% natural grass-fed clarified butter prepared using the traditional bilona method.',
      price: 24.50,
      stock: 250,
      imageUrl: 'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=500&auto=format&fit=crop&q=60',
      category: 'Food Products',
    ),
    CategoryItem(
      number: '26',
      title: 'Wholesale & Distribution',
      icon: Icons.local_shipping_rounded,
      color: Color(0xFF5E35B1),
      id: 'prod_26',
      name: 'Bulk Cardboard Shipping Box Pack (100 pcs)',
      description: 'High-density corrugated packaging boxes optimized for wholesale merchant shipping.',
      price: 65.00,
      stock: 80,
      imageUrl: 'https://images.unsplash.com/photo-1544816155-12df9643f363?w=500&auto=format&fit=crop&q=60',
      category: 'Wholesale & Distribution',
    ),
    CategoryItem(
      number: '27',
      title: 'Footwear & Bags',
      icon: Icons.shopping_basket_rounded,
      color: Color(0xFF8D6E63),
      id: 'prod_27',
      name: 'Athletic Running & Walking Shoes',
      description: 'Lightweight breathable sports shoes featuring memory foam insoles and dynamic shock absorption.',
      price: 59.99,
      stock: 140,
      imageUrl: 'https://images.unsplash.com/photo-1544816155-12df9643f363?w=500&auto=format&fit=crop&q=60',
      category: 'Footwear & Bags',
    ),
    CategoryItem(
      number: '28',
      title: 'Packaging Material, Supplies & Machines',
      icon: Icons.inventory_2_rounded,
      color: Color(0xFFFFA000),
      id: 'prod_28',
      name: 'Heavy Duty Bubble Wrap Roll (50m)',
      description: 'Premium protective bubble cushioning wrap designed for packaging fragile store products.',
      price: 18.90,
      stock: 220,
      imageUrl: 'https://images.unsplash.com/photo-1544816155-12df9643f363?w=500&auto=format&fit=crop&q=60',
      category: 'Packaging Material, Supplies & Machines',
    ),
    CategoryItem(
      number: '29',
      title: 'Chemicals, Dyes, Solvents & Allied Products',
      icon: Icons.science_rounded,
      color: Color(0xFF9C27B0),
      id: 'prod_29',
      name: 'High-Purity Isopropyl Alcohol Solvent (5L)',
      description: '99.9% pure cleaning agent and solvent optimized for industrial and lab sterilization purposes.',
      price: 32.00,
      stock: 75,
      imageUrl: 'https://images.unsplash.com/photo-1576092768241-dec231879fc3?w=500&auto=format&fit=crop&q=60',
      category: 'Chemicals, Dyes, Solvents & Allied Products',
    ),
    CategoryItem(
      number: '30',
      title: 'Common Available Items in Wholesale Market',
      icon: Icons.store_rounded,
      color: Color(0xFF1E88E5),
      id: 'prod_30',
      name: 'Assorted Bulk Plastic Storage Containers',
      description: 'Set of 50 heavy-duty plastic storage bins with airtight lock lids for retail vendors.',
      price: 85.00,
      stock: 130,
      imageUrl: 'https://images.unsplash.com/photo-1544816155-12df9643f363?w=500&auto=format&fit=crop&q=60',
      category: 'Common Available Items in Wholesale Market',
    ),
    CategoryItem(
      number: '31',
      title: 'Business & Professional Services',
      icon: Icons.business_center_rounded,
      color: Color(0xFF607D8B),
      id: 'prod_31',
      name: 'Brand Identity & Logo Design Suite',
      description: 'Full corporate rebranding package including custom logo, style guides, and digital assets.',
      price: 450.00,
      stock: 10,
      imageUrl: 'https://images.unsplash.com/photo-1497366216548-37526070297c?w=500&auto=format&fit=crop&q=60',
      category: 'Business & Professional Services',
    ),
    CategoryItem(
      number: '32',
      title: 'Security & Safety Services',
      icon: Icons.security_rounded,
      color: Color(0xFF3949AB),
      id: 'prod_32',
      name: 'CCTV Surveillance Security Camera (4-Pack)',
      description: 'Weatherproof high-definition outdoor security cameras with night vision and mobile app integration.',
      price: 199.99,
      stock: 40,
      imageUrl: 'https://images.unsplash.com/photo-1450133064473-71024230f91b?w=500&auto=format&fit=crop&q=60',
      category: 'Security & Safety Services',
    ),
    CategoryItem(
      number: '33',
      title: 'Religious & Spiritual Services',
      icon: Icons.account_balance_rounded,
      color: Color(0xFFFF8F00),
      id: 'prod_33',
      name: 'Handcrafted Premium Brass Puja Thali Set',
      description: 'Complete ceremonial brass worship set containing oil lamp, incense holder, and sacred vessels.',
      price: 49.00,
      stock: 60,
      imageUrl: 'https://images.unsplash.com/photo-1576092768241-dec231879fc3?w=500&auto=format&fit=crop&q=60',
      category: 'Religious & Spiritual Services',
    ),
    CategoryItem(
      number: '34',
      title: 'Rental & Hire Services',
      icon: Icons.vpn_key_rounded,
      color: Color(0xFF00897B),
      id: 'prod_34',
      name: 'High-Performance Business Laptop Rental',
      description: 'Weekly lease for powerful modern workstation laptop loaded with standard enterprise productivity software.',
      price: 55.00,
      stock: 25,
      imageUrl: 'https://images.unsplash.com/photo-1497366216548-37526070297c?w=500&auto=format&fit=crop&q=60',
      category: 'Rental & Hire Services',
    ),
    CategoryItem(
      number: '35',
      title: 'Green & Eco Services',
      icon: Icons.eco_rounded,
      color: Color(0xFF43A047),
      id: 'prod_35',
      name: 'Rooftop Solar Panel Installation Consultation',
      description: 'Professional energy assessment and rooftop layout design for off-grid solar panel arrays.',
      price: 99.00,
      stock: 15,
      imageUrl: 'https://images.unsplash.com/photo-1576092768241-dec231879fc3?w=500&auto=format&fit=crop&q=60',
      category: 'Green & Eco Services',
    ),
    CategoryItem(
      number: '36',
      title: 'Hyperlocal On-Demand Services',
      icon: Icons.moped_rounded,
      color: Color(0xFFF4511E),
      id: 'prod_36',
      name: 'Express Same-Day Electric Courier Delivery',
      description: 'Immediate hyperlocal package delivery dispatch using our eco-friendly active electric scooter fleet.',
      price: 15.00,
      stock: 500,
      imageUrl: 'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=500&auto=format&fit=crop&q=60',
      category: 'Hyperlocal On-Demand Services',
    ),
    CategoryItem(
      number: '37',
      title: 'Home Services',
      icon: Icons.home_repair_service_rounded,
      color: Color(0xFF1E88E5),
      id: 'prod_37',
      name: 'Professional Deep Home Cleaning Package',
      description: 'Complete interior home sanitation service utilizing premium non-toxic chemical cleaning solutions.',
      price: 120.00,
      stock: 30,
      imageUrl: 'https://images.unsplash.com/photo-1497366216548-37526070297c?w=500&auto=format&fit=crop&q=60',
      category: 'Home Services',
    ),
  ];

  // Returns subcategories for a given category name (focusing on Home Services)
  static List<SubCategoryItem> getSubCategoriesFor(String categoryTitle) {
    if (categoryTitle == 'Home Services') {
      return const [
        SubCategoryItem(
          id: 'sub_home_ac_repair',
          title: 'AC Repair Service',
          icon: Icons.ac_unit_rounded,
          color: Color(0xFF2196F3),
        ),
        SubCategoryItem(
          id: 'sub_home_ac_compressor',
          title: 'AC Compressor Repair',
          icon: Icons.build_rounded,
          color: Color(0xFFFF9800),
        ),
        SubCategoryItem(
          id: 'sub_home_fan_motor',
          title: 'Fan Motor Repair',
          icon: Icons.toys_rounded,
          color: Color(0xFF009688),
        ),
        SubCategoryItem(
          id: 'sub_home_appliance',
          title: 'Appliance Repair',
          icon: Icons.wash_rounded,
          color: Color(0xFF3F51B5),
        ),
        SubCategoryItem(
          id: 'sub_home_electrical',
          title: 'Electrical Services',
          icon: Icons.bolt_rounded,
          color: Color(0xFFFF5722),
        ),
        SubCategoryItem(
          id: 'sub_home_plumbing',
          title: 'Plumbing Services',
          icon: Icons.plumbing_rounded,
          color: Color(0xFF03A9F4),
        ),
        SubCategoryItem(
          id: 'sub_home_pest',
          title: 'Pest Control Services',
          icon: Icons.bug_report_rounded,
          color: Color(0xFFE91E63),
        ),
        SubCategoryItem(
          id: 'sub_home_support',
          title: '24/7 Support',
          icon: Icons.support_agent_rounded,
          color: Color(0xFF4CAF50),
        ),
      ];
    }
    
    // For other super categories, return dynamic or dummy subcategories so the app has high fidelity
    if (categoryTitle == 'Food Products') {
      return const [
        SubCategoryItem(
          id: 'sub_food_veg',
          title: 'Fruits & Veg',
          icon: Icons.agriculture_rounded,
          color: Color(0xFF4CAF50),
        ),
        SubCategoryItem(
          id: 'sub_food_dairy',
          title: 'Dairy & Eggs',
          icon: Icons.egg_rounded,
          color: Color(0xFFFFC107),
        ),
        SubCategoryItem(
          id: 'sub_food_bakery',
          title: 'Bakery & Bread',
          icon: Icons.bakery_dining_rounded,
          color: Color(0xFF8D6E63),
        ),
        SubCategoryItem(
          id: 'sub_food_beverages',
          title: 'Beverages',
          icon: Icons.local_drink_rounded,
          color: Color(0xFF00BCD4),
        ),
      ];
    }
    
    return const [];
  }

  // Returns nested sub-subcategories (service types) for a given subcategory title (e.g. Pest Control Services)
  static List<SubSubCategoryItem> getServiceTypesFor(String subcategoryTitle) {
    if (subcategoryTitle == 'Pest Control Services') {
      return const [
        SubSubCategoryItem(
          id: 'ss_pest_bedbugs',
          title: 'Bed Bugs',
          icon: Icons.bug_report_rounded,
          color: Color(0xFFE91E63),
        ),
        SubSubCategoryItem(
          id: 'ss_pest_cockroach',
          title: 'Cockroach Control',
          icon: Icons.pest_control_rounded,
          color: Color(0xFFFF9800),
        ),
        SubSubCategoryItem(
          id: 'ss_pest_ant',
          title: 'Ant Control',
          icon: Icons.pest_control_rodent_rounded,
          color: Color(0xFF9C27B0),
        ),
        SubSubCategoryItem(
          id: 'ss_pest_lizards',
          title: 'Lizards Control',
          icon: Icons.healing_rounded,
          color: Color(0xFF009688),
        ),
        SubSubCategoryItem(
          id: 'ss_pest_termite',
          title: 'Terminate Control',
          icon: Icons.coronavirus_rounded,
          color: Color(0xFFE53935),
        ),
      ];
    }
    
    // For other subcategories, return dynamic sub-subcategories
    if (subcategoryTitle == 'AC Repair Service') {
      return const [
        SubSubCategoryItem(
          id: 'ss_ac_split',
          title: 'Split AC Service',
          icon: Icons.ac_unit_rounded,
          color: Color(0xFF2196F3),
        ),
        SubSubCategoryItem(
          id: 'ss_ac_window',
          title: 'Window AC Service',
          icon: Icons.filter_rounded,
          color: Color(0xFF00BCD4),
        ),
        SubSubCategoryItem(
          id: 'ss_ac_gas',
          title: 'Gas Charging',
          icon: Icons.speed_rounded,
          color: Color(0xFF4CAF50),
        ),
      ];
    }
    
    return const [];
  }

  // Static list of sample products dynamically mapped from the enriched categories
  static final List<ProductModel> sampleProducts =
      categories.map((c) => c.toProductModel()).toList();
}

class SubSubCategoryItem {
  final String id;
  final String title;
  final IconData icon;
  final Color color;
  final double? amount;
  final double? discountedPrice;

  const SubSubCategoryItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    this.amount,
    this.discountedPrice,
  });
}


class SubCategoryItem {
  final String id;
  final String title;
  final IconData icon;
  final Color color;
  final String? iconUrl;

  const SubCategoryItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    this.iconUrl,
  });
}


class CategoryItem {
  final String number;
  final String title;
  final IconData icon;
  final Color color;

  // Enriched fields to map directly to a ProductModel
  final String id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String imageUrl;
  final String category;
  final bool hasSubcategories;

  const CategoryItem({
    required this.number,
    required this.title,
    required this.icon,
    required this.color,
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.imageUrl,
    required this.category,
    this.hasSubcategories = false,
  });

  ProductModel toProductModel() {
    return ProductModel(
      id: id,
      name: name,
      description: description,
      price: price,
      stock: stock,
      imageUrl: imageUrl,
      category: category,
    );
  }
}
