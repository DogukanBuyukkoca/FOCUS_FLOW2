// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:glass_kit/glass_kit.dart';
// import 'package:purchases_flutter/purchases_flutter.dart';
// import 'app_theme.dart';
// import 'providers.dart';
// import 'models.dart';

// class PremiumPage extends ConsumerStatefulWidget {
//   const PremiumPage({super.key});

//   @override
//   ConsumerState<PremiumPage> createState() => _PremiumPageState();
// }

// class _PremiumPageState extends ConsumerState<PremiumPage> {
//   bool _isMonthly = true;
//   bool _isLoading = false;
  
//   final List<PremiumFeature> _features = [
//     PremiumFeature(
//       icon: Icons.insights_rounded,
//       title: 'Advanced Analytics',
//       description: 'Deep insights into your productivity patterns',
//       color: Colors.blue,
//     ),
//     PremiumFeature(
//       icon: Icons.cloud_sync_rounded,
//       title: 'Cloud Sync',
//       description: 'Sync across all your devices seamlessly',
//       color: Colors.green,
//     ),
//     PremiumFeature(
//       icon: Icons.download_rounded,
//       title: 'Unlimited Export',
//       description: 'Export your data in CSV, JSON formats',
//       color: Colors.orange,
//     ),
//     PremiumFeature(
//       icon: Icons.music_note_rounded,
//       title: 'Premium Sounds',
//       description: 'Focus music and ambient soundscapes',
//       color: Colors.purple,
//     ),
//     PremiumFeature(
//       icon: Icons.palette_rounded,
//       title: 'Custom Themes',
//       description: 'Personalize with exclusive themes',
//       color: Colors.pink,
//     ),
//     PremiumFeature(
//       icon: Icons.all_inclusive_rounded,
//       title: 'No Limits',
//       description: 'Unlimited goals, sessions, and more',
//       color: Colors.red,
//     ),
//   ];
  
//   void _restorePurchases() async {
//     setState(() {
//       _isLoading = true;
//     });
    
//     try {
//       await Purchases.restorePurchases();
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//            SnackBar(
//             content: Text('Purchases restored successfully'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Failed to restore purchases: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }
  
//   void _startTrial() async {
//     setState(() {
//       _isLoading = true;
//     });
    
//     try {
//       final offerings = await Purchases.getOfferings();
//       if (offerings.current != null) {
//         final package = _isMonthly
//             ? offerings.current!.availablePackages.firstWhere(
//                 (p) => p.identifier == 'pro_month',
//                 orElse: () => offerings.current!.availablePackages.first,
//               )
//             : offerings.current!.availablePackages.firstWhere(
//                 (p) => p.identifier == 'pro_year',
//                 orElse: () => offerings.current!.availablePackages.first,
//               );
        
//         await Purchases.purchasePackage(package);
        
//         if (mounted) {
//           Navigator.of(context).pop();
//           ScaffoldMessenger.of(context).showSnackBar(
//              SnackBar(
//               content: Text('Welcome to Premium!'),
//               backgroundColor: Colors.green,
//             ),
//           );
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Purchase failed: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }
  
//   Widget _buildFeatureCard(PremiumFeature feature) {
//     final theme = Theme.of(context);
    
//     return Container(
//       padding: const EdgeInsets.all(AppTheme.spacing12),
//       decoration: BoxDecoration(
//         color: theme.colorScheme.surface,
//         borderRadius: BorderRadius.circular(AppTheme.radius16),
//         border: Border.all(
//           color: feature.color.withOpacity(0.3),
//           width: 1,
//         ),
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 48,
//             height: 48,
//             decoration: BoxDecoration(
//               color: feature.color.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(AppTheme.radius12),
//             ),
//             child: Icon(
//               feature.icon,
//               color: feature.color,
//               size: 24,
//             ),
//           ),
//            SizedBox(width: AppTheme.spacing8),
//           Text(
//             feature.title,
//             style: theme.textTheme.bodyMedium?.copyWith(
//               fontWeight: FontWeight.w600,
//             overflow: TextOverflow.ellipsis,
//             ),
//           ),
//            SizedBox(width: AppTheme.spacing4),
//           Text(
//             feature.description,
//             style: theme.textTheme.bodySmall?.copyWith(
//               color: theme.colorScheme.onSurface.withOpacity(0.6),
//               overflow: TextOverflow.ellipsis,
//             ),
            
//           ),
//         ],
//       ),
//     );
//   }
  
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final offerings = ref.watch(premiumOfferingsProvider);
    
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               AppTheme.primaryColor.withOpacity(0.1),
//               AppTheme.secondaryColor.withOpacity(0.1),
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: Stack(
//             children: [
//               // Background Pattern
//               Positioned.fill(
//                 child: CustomPaint(
//                   painter: PremiumBackgroundPainter(
//                     color: AppTheme.primaryColor.withOpacity(0.05),
//                   ),
//                 ),
//               ),
              
//               // Content
//               CustomScrollView(
//                 physics: const BouncingScrollPhysics(),
//                 slivers: [
//                   // App Bar
//                   SliverAppBar(
//                     floating: true,
//                     backgroundColor: Colors.transparent,
//                     elevation: 0,
//                     leading: IconButton(
//                       icon: const Icon(Icons.close_rounded),
//                       onPressed: () => Navigator.of(context).pop(),
//                     ),
//                     actions: [
//                       TextButton(
//                         onPressed: _restorePurchases,
//                         child: const Text('Restore'),
//                       ),
//                     ],
//                   ),
                  
//                   // Header
//                   SliverToBoxAdapter(
//                     child: Padding(
//                       padding: const EdgeInsets.all(AppTheme.spacing20),
//                       child: Column(
//                         children: [
//                           // Premium Badge
//                           Container(
//                             width: 100,
//                             height: 100,
//                             decoration: BoxDecoration(
//                               gradient: AppTheme.primaryGradient,
//                               shape: BoxShape.circle,
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: AppTheme.primaryColor.withOpacity(0.3),
//                                   blurRadius: 20,
//                                   offset: const Offset(0, 10),
//                                 ),
//                               ],
//                             ),
//                             child: const Icon(
//                               Icons.workspace_premium_rounded,
//                               size: 50,
//                               color: Colors.white,
//                             ),
//                           ).animate()
//                             .scale(duration: AppTheme.animSlow)
//                             .then()
//                             .shimmer(duration: const Duration(seconds: 2), delay: const Duration(seconds: 1)),
                          
//                           const SizedBox(height: AppTheme.spacing24),
                          
//                           // Title
//                           Text(
//                             'Unlock Your Full Potential',
//                             style: theme.textTheme.headlineMedium?.copyWith(
//                               fontWeight: FontWeight.bold,
//                               foreground: Paint()
//                                 ..shader = AppTheme.primaryGradient.createShader(
//                                   const Rect.fromLTWH(0.0, 0.0, 300.0, 70.0),
//                                 ),
//                             ),
//                             textAlign: TextAlign.center,
//                           ).animate().fadeIn(delay: 100.ms),
                          
//                           const SizedBox(height: AppTheme.spacing12),
                          
//                           // Subtitle
//                           Text(
//                             'Get unlimited access to all premium features',
//                             style: theme.textTheme.bodyLarge?.copyWith(
//                               color: theme.colorScheme.onSurface.withOpacity(0.7),
//                             ),
//                             textAlign: TextAlign.center,
//                           ).animate().fadeIn(delay: 200.ms),
                          
//                           const SizedBox(height: AppTheme.spacing32),
                          
//                           // Free Trial Badge
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: AppTheme.spacing16,
//                               vertical: AppTheme.spacing8,
//                             ),
//                             decoration: BoxDecoration(
//                               color: Colors.green.withOpacity(0.1),
//                               borderRadius: BorderRadius.circular(AppTheme.radius24),
//                               border: Border.all(
//                                 color: Colors.green.withOpacity(0.3),
//                                 width: 1,
//                               ),
//                             ),
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 const Icon(
//                                   Icons.check_circle_rounded,
//                                   color: Colors.green,
//                                   size: 20,
//                                 ),
//                                 const SizedBox(width: AppTheme.spacing8),
//                                 Text(
//                                   '7 Days Free Trial',
//                                   style: theme.textTheme.bodyMedium?.copyWith(
//                                     color: Colors.green,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ).animate()
//                             .fadeIn(delay: 300.ms)
//                             .scale()
//                             .then()
//                             .shimmer(duration: const Duration(seconds: 2), delay: const Duration(seconds: 2)),
//                         ],
//                       ),
//                     ),
//                   ),
                  
//                   // Features Grid
//                   SliverPadding(
//                     padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing20),
//                     sliver: SliverGrid(
//                       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 2,
//                         childAspectRatio: 1.2,
//                         crossAxisSpacing: AppTheme.spacing12,
//                         mainAxisSpacing: AppTheme.spacing12,
//                       ),
//                       delegate: SliverChildBuilderDelegate(
//                         (context, index) {
//                           final feature = _features[index];
//                           return _buildFeatureCard(feature)
//                               .animate()
//                               .fadeIn(delay: (400 + index * 50).ms)
//                               .scale();
//                         },
//                         childCount: _features.length,
//                       ),
//                     ),
//                   ),
                  
//                   // Pricing Options
//                   SliverToBoxAdapter(
//                     child: Padding(
//                       padding: const EdgeInsets.all(AppTheme.spacing20),
//                       child: Column(
//                         children: [
//                           const SizedBox(height: AppTheme.spacing20),
                          
//                           // Plan Toggle
//                           Container(
//                             padding: const EdgeInsets.all(4),
//                             decoration: BoxDecoration(
//                               color: theme.colorScheme.surface,
//                               borderRadius: BorderRadius.circular(AppTheme.radius12),
//                               border: Border.all(
//                                 color: theme.colorScheme.onSurface.withOpacity(0.1),
//                                 width: 1,
//                               ),
//                             ),
//                             child: Row(
//                               children: [
//                                 Expanded(
//                                   child: GestureDetector(
//                                     onTap: () {
//                                       HapticFeedback.lightImpact();
//                                       setState(() {
//                                         _isMonthly = true;
//                                       });
//                                     },
//                                     child: AnimatedContainer(
//                                       duration: AppTheme.animBase,
//                                       padding: const EdgeInsets.symmetric(
//                                         vertical: AppTheme.spacing12,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         color: _isMonthly
//                                             ? AppTheme.primaryColor
//                                             : Colors.transparent,
//                                         borderRadius: BorderRadius.circular(AppTheme.radius8),
//                                       ),
//                                       child: Text(
//                                         'Monthly',
//                                         style: theme.textTheme.bodyLarge?.copyWith(
//                                           color: _isMonthly
//                                               ? Colors.white
//                                               : theme.colorScheme.onSurface,
//                                           fontWeight: FontWeight.w600,
//                                         ),
//                                         textAlign: TextAlign.center,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 Expanded(
//                                   child: GestureDetector(
//                                     onTap: () {
//                                       HapticFeedback.lightImpact();
//                                       setState(() {
//                                         _isMonthly = false;
//                                       });
//                                     },
//                                     child: AnimatedContainer(
//                                       duration: AppTheme.animBase,
//                                       padding: const EdgeInsets.symmetric(
//                                         vertical: AppTheme.spacing12,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         color: !_isMonthly
//                                             ? AppTheme.primaryColor
//                                             : Colors.transparent,
//                                         borderRadius: BorderRadius.circular(AppTheme.radius8),
//                                       ),
//                                       child: Column(
//                                         children: [
//                                           Text(
//                                             'Yearly',
//                                             style: theme.textTheme.bodyLarge?.copyWith(
//                                               color: !_isMonthly
//                                                   ? Colors.white
//                                                   : theme.colorScheme.onSurface,
//                                               fontWeight: FontWeight.w600,
//                                             ),
//                                             textAlign: TextAlign.center,
//                                           ),
//                                           if (!_isMonthly)
//                                             Text(
//                                               'Save 35%',
//                                               style: theme.textTheme.labelSmall?.copyWith(
//                                                 color: Colors.white.withOpacity(0.9),
//                                               ),
//                                             ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.1),
                          
//                           const SizedBox(height: AppTheme.spacing20),
                          
//                           // Price Display
//                           offerings.when(
//                             data: (packages) {
//                               if (packages.isEmpty) {
//                                 return Column(
//                                   children: [
//                                     Text(
//                                       _isMonthly ? '\$4.99' : '\$39.99',
//                                       style: theme.textTheme.displaySmall?.copyWith(
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                     Text(
//                                       _isMonthly ? 'per month' : 'per year',
//                                       style: theme.textTheme.bodyLarge?.copyWith(
//                                         color: theme.colorScheme.onSurface.withOpacity(0.6),
//                                       ),
//                                     ),
//                                   ],
//                                 );
//                               }
                              
//                               final package = _isMonthly 
//                                   ? packages.firstWhere(
//                                       (p) => p.identifier == 'pro_month',
//                                       orElse: () => packages.first,
//                                     )
//                                   : packages.firstWhere(
//                                       (p) => p.identifier == 'pro_year', 
//                                       orElse: () => packages.first,
//                                     );
                              
//                               return Column(
//                                 children: [
//                                   Text(
//                                     package.priceString,
//                                     style: theme.textTheme.displaySmall?.copyWith(
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ).animate().fadeIn(delay: 800.ms).scale(),
                                  
//                                   Text(
//                                     _isMonthly ? 'per month' : 'per year',
//                                     style: theme.textTheme.bodyLarge?.copyWith(
//                                       color: theme.colorScheme.onSurface.withOpacity(0.6),
//                                     ),
//                                   ),
//                                 ],
//                               );
//                             },
//                             loading: () => const CircularProgressIndicator(),
//                             error: (error, stack) => Text('Error: $error'),
//                           ),
                          
//                           const SizedBox(height: AppTheme.spacing32),
//                         ],
//                       ),
//                     ),
//                   ),
                  
//                   // Bottom Padding
//                   const SliverToBoxAdapter(
//                     child: SizedBox(height: 100),
//                   ),
//                 ],
//               ),
              
//               // Bottom CTA
//               Positioned(
//                 bottom: 0,
//                 left: 0,
//                 right: 0,
//                 child: Container(
//                   padding: const EdgeInsets.all(AppTheme.spacing20),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.bottomCenter,
//                       end: Alignment.topCenter,
//                       colors: [
//                         theme.scaffoldBackgroundColor,
//                         theme.scaffoldBackgroundColor.withOpacity(0.9),
//                         theme.scaffoldBackgroundColor.withOpacity(0),
//                       ],
//                     ),
//                   ),
//                   child: ElevatedButton(
//                     onPressed: _isLoading ? null : _startTrial,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppTheme.primaryColor,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(
//                         vertical: AppTheme.spacing16,
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(AppTheme.radius12),
//                       ),
//                     ),
//                     child: _isLoading
//                         ? const SizedBox(
//                             height: 20,
//                             width: 20,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                             ),
//                           )
//                         : const Text(
//                             'Start 7-Day Free Trial',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                   ),
//                 ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.2),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // Premium Background Painter
// class PremiumBackgroundPainter extends CustomPainter {
//   final Color color;
  
//   PremiumBackgroundPainter({required this.color});
  
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = color
//       ..style = PaintingStyle.fill;
    
//     // Draw decorative circles
//     canvas.drawCircle(
//       Offset(size.width * 0.2, size.height * 0.1),
//       60,
//       paint,
//     );
    
//     canvas.drawCircle(
//       Offset(size.width * 0.8, size.height * 0.3),
//       80,
//       paint,
//     );
    
//     canvas.drawCircle(
//       Offset(size.width * 0.3, size.height * 0.6),
//       40,
//       paint,
//     );
    
//     canvas.drawCircle(
//       Offset(size.width * 0.7, size.height * 0.8),
//       70,
//       paint,
//     );
//   }
  
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }
                                
//                   // Features Grid
//                   SliverPadding(
//                     padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing20),
//                     sliver: SliverGrid(
//                       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 2,
//                         childAspectRatio: 1.2,
//                         crossAxisSpacing: AppTheme.spacing12,
//                         mainAxisSpacing: AppTheme.spacing12,
//                       ),
//                       delegate: SliverChildBuilderDelegate(
//                         (context, index) {
//                           final feature = _features[index];
//                           return _buildFeatureCard(feature)
//                               .animate()
//                               .fadeIn(delay: (400 + index * 50).ms)
//                               .scale();
//                         },
//                         childCount: _features.length,
//                       ),
//                     ),
//                   ),
                  
//                   // Pricing Options
//                   SliverToBoxAdapter(
//                     child: Padding(
//                       padding: const EdgeInsets.all(AppTheme.spacing20),
//                       child: Column(
//                         children: [
//                           const SizedBox(height: AppTheme.spacing20),
                          
//                           // Plan Toggle
//                           Container(
//                             padding: const EdgeInsets.all(4),
//                             decoration: BoxDecoration(
//                               color: theme.colorScheme.surface,
//                               borderRadius: BorderRadius.circular(AppTheme.radius12),
//                               border: Border.all(
//                                 color: theme.colorScheme.onSurface.withOpacity(0.1),
//                                 width: 1,
//                               ),
//                             ),
//                             child: Row(
//                               children: [
//                                 Expanded(
//                                   child: GestureDetector(
//                                     onTap: () {
//                                       HapticFeedback.lightImpact();
//                                       setState(() {
//                                         _isMonthly = true;
//                                       });
//                                     },
//                                     child: AnimatedContainer(
//                                       duration: AppTheme.animBase,
//                                       padding: const EdgeInsets.symmetric(
//                                         vertical: AppTheme.spacing12,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         color: _isMonthly
//                                             ? AppTheme.primaryColor
//                                             : Colors.transparent,
//                                         borderRadius: BorderRadius.circular(AppTheme.radius8),
//                                       ),
//                                       child: Text(
//                                         'Monthly',
//                                         style: theme.textTheme.bodyLarge?.copyWith(
//                                           color: _isMonthly
//                                               ? Colors.white
//                                               : theme.colorScheme.onSurface,
//                                           fontWeight: FontWeight.w600,
//                                         ),
//                                         textAlign: TextAlign.center,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 Expanded(
//                                   child: GestureDetector(
//                                     onTap: () {
//                                       HapticFeedback.lightImpact();
//                                       setState(() {
//                                         _isMonthly = false;
//                                       });
//                                     },
//                                     child: AnimatedContainer(
//                                       duration: AppTheme.animBase,
//                                       padding: const EdgeInsets.symmetric(
//                                         vertical: AppTheme.spacing12,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         color: !_isMonthly
//                                             ? AppTheme.primaryColor
//                                             : Colors.transparent,
//                                         borderRadius: BorderRadius.circular(AppTheme.radius8),
//                                       ),
//                                       child: Column(
//                                         children: [
//                                           Text(
//                                             'Yearly',
//                                             style: theme.textTheme.bodyLarge?.copyWith(
//                                               color: !_isMonthly
//                                                   ? Colors.white
//                                                   : theme.colorScheme.onSurface,
//                                               fontWeight: FontWeight.w600,
//                                             ),
//                                             textAlign: TextAlign.center,
//                                           ),
//                                           if (!_isMonthly)
//                                             Text(
//                                               'Save 35%',
//                                               style: theme.textTheme.labelSmall?.copyWith(
//                                                 color: Colors.white.withOpacity(0.9),
//                                               ),
//                                             ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.1),
                          
//                           const SizedBox(height: AppTheme.spacing20),
                          
//                           // Price Display
//                           offerings.when(
//                             data: (packages) {
//                               if (packages.isEmpty) {
//                                 return Text(
//                                   _isMonthly ? '\$4.99/month' : '\$39.99/year',
//                                   style: theme.textTheme.displaySmall?.copyWith(
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 );
//                               }
                              
//                               final package = _isMonthly 
//                                   ? packages.firstWhere(
//                                       (p) => p.identifier == 'pro_month',
//                                       orElse: () => packages.first,
//                                     )
//                                   : packages.firstWhere(
//                                       (p) => p.identifier == 'pro_year', 
//                                       orElse: () => packages.first,
//                                     );
                              
//                               return Column(
//                                 children: [
//                                   Text(
//                                     package.storeProduct.priceString,
//                                     style: theme.textTheme.displaySmall?.copyWith(
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ).animate().fadeIn(delay: 800.ms).scale(),
                                  
//                                   Text(
//                                     _isMonthly ? 'per month' : 'per year',
//                                     style: theme.textTheme.bodyLarge?.copyWith(
//                                       color: theme.colorScheme.onSurface.withOpacity(0.6),
//                                     ),
//                                   ),
//                                 ],
//                               );
//                             },
//                             loading: () => const CircularProgressIndicator(),
//                             error: (error, stack) => Text('Error: $error'),
//                           ),
                          
//                           const SizedBox(height: AppTheme.spacing32),
//                         ],
//                       ),
//                     ),
//                   ),
                  
//                   // Bottom Padding
//                   const SliverToBoxAdapter(
//                     child: SizedBox(height: 100),
//                   ),
//                 ],
//               ),
              
//               // Bottom CTA
//               Positioned(
//                 bottom: 0,
//                 left: 0,
//                 right: 0,
//                 child: Container(
//                   padding: const EdgeInsets.all(AppTheme.spacing20),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.bottomCenter,
//                       end: Alignment.topCenter,
//                       colors: [
//                         theme.scaffoldBackgroundColor,
//                         theme.scaffoldBackgroundColor.withOpacity(0.9),
//                         theme.scaffoldBackgroundColor.withOpacity(0),
//                       ],
//                     ),
//                   ),
//                   child: ElevatedButton(
//                     onPressed: _isLoading ? null : _startTrial,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppTheme.primaryColor,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(
//                         vertical: AppTheme.spacing16,
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(AppTheme.radius12),
//                       ),
//                     ),
//                     child: _isLoading
//                         ? const SizedBox(
//                             height: 20,
//                             width: 20,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                             ),
//                           )
//                         : const Text(
//                             'Start 7-Day Free Trial',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                   ),
//                 ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.2),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // Premium Background Painter
// class PremiumBackgroundPainter extends CustomPainter {
//   final Color color;
  
//   PremiumBackgroundPainter({required this.color});
  
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = color
//       ..style = PaintingStyle.fill;
    
//     // Draw decorative circles
//     canvas.drawCircle(
//       Offset(size.width * 0.2, size.height * 0.1),
//       60,
//       paint,
//     );
    
//     canvas.drawCircle(
//       Offset(size.width * 0.8, size.height * 0.3),
//       80,
//       paint,
//     );
    
//     canvas.drawCircle(
//       Offset(size.width * 0.3, size.height * 0.6),
//       40,
//       paint,
//     );
    
//     canvas.drawCircle(
//       Offset(size.width * 0.7, size.height * 0.8),
//       70,
//       paint,
//     );
//   }
  
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }

// class PremiumPage extends ConsumerStatefulWidget {
//   const PremiumPage({super.key});

//   @override
//   ConsumerState<PremiumPage> createState() => _PremiumPageState();
// }

// class _PremiumPageState extends ConsumerState<PremiumPage> {
//   bool _isMonthly = true;
//   bool _isLoading = false;
  
//   final List<PremiumFeature> _features = [
//     PremiumFeature(
//       icon: Icons.insights_rounded,
//       title: 'Advanced Analytics',
//       description: 'Deep insights into your productivity patterns',
//       color: Colors.blue,
//     ),
//     PremiumFeature(
//       icon: Icons.cloud_sync_rounded,
//       title: 'Cloud Sync',
//       description: 'Sync across all your devices seamlessly',
//       color: Colors.green,
//     ),
//     PremiumFeature(
//       icon: Icons.download_rounded,
//       title: 'Unlimited Export',
//       description: 'Export your data in CSV, JSON formats',
//       color: Colors.orange,
//     ),
//     PremiumFeature(
//       icon: Icons.music_note_rounded,
//       title: 'Premium Sounds',
//       description: 'Focus music and ambient soundscapes',
//       color: Colors.purple,
//     ),
//     PremiumFeature(
//       icon: Icons.palette_rounded,
//       title: 'Custom Themes',
//       description: 'Personalize with exclusive themes',
//       color: Colors.pink,
//     ),
//     PremiumFeature(
//       icon: Icons.all_inclusive_rounded,
//       title: 'No Limits',
//       description: 'Unlimited goals, sessions, and more',
//       color: Colors.red,
//     ),
//   ];
  
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;
//     final size = MediaQuery.of(context).size;
//     final offerings = ref.watch(premiumOfferingsProvider);
    
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               AppTheme.primaryColor.withOpacity(0.1),
//               AppTheme.secondaryColor.withOpacity(0.1),
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: Stack(
//             children: [
//               // Background Pattern
//               Positioned.fill(
//                 child: CustomPaint(
//                   painter: PremiumBackgroundPainter(
//                     color: AppTheme.primaryColor.withOpacity(0.05),
//                   ),
//                 ),
//               ),
              
//               // Content
//               CustomScrollView(
//                 physics: const BouncingScrollPhysics(),
//                 slivers: [
//                   // App Bar
//                   SliverAppBar(
//                     floating: true,
//                     backgroundColor: Colors.transparent,
//                     elevation: 0,
//                     leading: IconButton(
//                       icon: const Icon(Icons.close_rounded),
//                       onPressed: () => Navigator.of(context).pop(),
//                     ),
//                     actions: [
//                       TextButton(
//                         onPressed: _restorePurchases,
//                         child: const Text('Restore'),
//                       ),
//                     ],
//                   ),
                  
//                   // Header
//                   SliverToBoxAdapter(
//                     child: Padding(
//                       padding: const EdgeInsets.all(AppTheme.spacing20),
//                       child: Column(
//                         children: [
//                           // Premium Badge
//                           Container(
//                             width: 100,
//                             height: 100,
//                             decoration: BoxDecoration(
//                               gradient: AppTheme.primaryGradient,
//                               shape: BoxShape.circle,
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: AppTheme.primaryColor.withOpacity(0.3),
//                                   blurRadius: 20,
//                                   offset: const Offset(0, 10),
//                                 ),
//                               ],
//                             ),
//                             child: const Icon(
//                               Icons.workspace_premium_rounded,
//                               size: 50,
//                               color: Colors.white,
//                             ),
//                           ).animate()
//                             .scale(duration: AppTheme.animSlow)
//                             .then()
//                             .shimmer(duration: 2.seconds, delay: 1.second),
                          
//                           const SizedBox(height: AppTheme.spacing24),
                          
//                           // Title
//                           Text(
//                             'Unlock Your Full Potential',
//                             style: theme.textTheme.headlineMedium?.copyWith(
//                               fontWeight: FontWeight.bold,
//                               foreground: Paint()
//                                 ..shader = AppTheme.primaryGradient.createShader(
//                                   const Rect.fromLTWH(0.0, 0.0, 300.0, 70.0),
//                                 ),
//                             ),
//                             textAlign: TextAlign.center,
//                           ).animate().fadeIn(delay: 100.ms),
                          
//                           const SizedBox(height: AppTheme.spacing12),
                          
//                           // Subtitle
//                           Text(
//                             'Get unlimited access to all premium features',
//                             style: theme.textTheme.bodyLarge?.copyWith(
//                               color: theme.colorScheme.onSurface.withOpacity(0.7),
//                             ),
//                             textAlign: TextAlign.center,
//                           ).animate().fadeIn(delay: 200.ms),
                          
//                           const SizedBox(height: AppTheme.spacing32),
                          
//                           // Free Trial Badge
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: AppTheme.spacing16,
//                               vertical: AppTheme.spacing8,
//                             ),
//                             decoration: BoxDecoration(
//                               color: Colors.green.withOpacity(0.1),
//                               borderRadius: BorderRadius.circular(AppTheme.radius24),
//                               border: Border.all(
//                                 color: Colors.green.withOpacity(0.3),
//                                 width: 1,
//                               ),
//                             ),
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Icon(
//                                   Icons.check_circle_rounded,
//                                   color: Colors.green,
//                                   size: 20,
//                                 ),
//                                 const SizedBox(width: AppTheme.spacing8),
//                                 Text(
//                                   '7 Days Free Trial',
//                                   style: theme.textTheme.bodyMedium?.copyWith(
//                                     color: Colors.green,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ).animate()
//                             .fadeIn(delay: 300.ms)
//                             .scale()
//                             .then()
//                             .shimmer(duration: 2.seconds, delay: 2.seconds),
//                         ],
//                       ),
//                     ),
//                   ),
                  
//                   // Features Grid
//                   SliverPadding(
//                     padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing20),
//                     sliver: SliverGrid(
//                       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 2,
//                         childAspectRatio: 1.2,
//                         crossAxisSpacing: AppTheme.spacing12,
//                         mainAxisSpacing: AppTheme.spacing12,
//                       ),
//                       delegate: SliverChildBuilderDelegate(
//                         (context, index) {
//                           final feature = _features[index];
//                           return _buildFeatureCard(feature)
//                               .animate()
//                               .fadeIn(delay: (400 + index * 50).ms)
//                               .scale();
//                         },
//                         childCount: _features.length,
//                       ),
//                     ),
//                   ),
                  
//                   // Pricing Options
//                   SliverToBoxAdapter(
//                     child: Padding(
//                       padding: const EdgeInsets.all(AppTheme.spacing20),
//                       child: Column(
//                         children: [
//                           const SizedBox(height: AppTheme.spacing20),
                          
//                           // Plan Toggle
//                           Container(
//                             padding: const EdgeInsets.all(4),
//                             decoration: BoxDecoration(
//                               color: theme.colorScheme.surface,
//                               borderRadius: BorderRadius.circular(AppTheme.radius12),
//                               border: Border.all(
//                                 color: theme.colorScheme.onSurface.withOpacity(0.1),
//                                 width: 1,
//                               ),
//                             ),
//                             child: Row(
//                               children: [
//                                 Expanded(
//                                   child: GestureDetector(
//                                     onTap: () {
//                                       HapticFeedback.lightImpact();
//                                       setState(() {
//                                         _isMonthly = true;
//                                       });
//                                     },
//                                     child: AnimatedContainer(
//                                       duration: AppTheme.animBase,
//                                       padding: const EdgeInsets.symmetric(
//                                         vertical: AppTheme.spacing12,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         color: _isMonthly
//                                             ? AppTheme.primaryColor
//                                             : Colors.transparent,
//                                         borderRadius: BorderRadius.circular(AppTheme.radius8),
//                                       ),
//                                       child: Text(
//                                         'Monthly',
//                                         style: theme.textTheme.bodyLarge?.copyWith(
//                                           color: _isMonthly
//                                               ? Colors.white
//                                               : theme.colorScheme.onSurface,
//                                           fontWeight: FontWeight.w600,
//                                         ),
//                                         textAlign: TextAlign.center,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 Expanded(
//                                   child: GestureDetector(
//                                     onTap: () {
//                                       HapticFeedback.lightImpact();
//                                       setState(() {
//                                         _isMonthly = false;
//                                       });
//                                     },
//                                     child: AnimatedContainer(
//                                       duration: AppTheme.animBase,
//                                       padding: const EdgeInsets.symmetric(
//                                         vertical: AppTheme.spacing12,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         color: !_isMonthly
//                                             ? AppTheme.primaryColor
//                                             : Colors.transparent,
//                                         borderRadius: BorderRadius.circular(AppTheme.radius8),
//                                       ),
//                                       child: Column(
//                                         children: [
//                                           Text(
//                                             'Yearly',
//                                             style: theme.textTheme.bodyLarge?.copyWith(
//                                               color: !_isMonthly
//                                                   ? Colors.white
//                                                   : theme.colorScheme.onSurface,
//                                               fontWeight: FontWeight.w600,
//                                             ),
//                                             textAlign: TextAlign.center,
//                                           ),
//                                           if (!_isMonthly)
//                                             Text(
//                                               'Save 35%',
//                                               style: theme.textTheme.labelSmall?.copyWith(
//                                                 color: Colors.white.withOpacity(0.9),
//                                               ),
//                                             ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.1),
                          
//                           const SizedBox(height: AppTheme.spacing20),
                          
//                           // Price Display
//                           offerings.when(
//                             data: (packages) {
//                               final package = _isMonthly 
//                                   ? packages.firstWhere((p) => p.identifier == 'pro_month')
//                                   : packages.firstWhere((p) => p.identifier == 'pro_year');
                              
//                               return Column(
//                                 children: [
//                                   Text(
//                                     package.storeProduct.priceString,
//                                     style: theme.textTheme.displaySmall?.copyWith(
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ).animate().fadeIn(delay: 800.ms).scale(),
                                  
//                                   Text(
//                                     _isMonthly ? 'per month' : 'per year',
//                                     style: theme.textTheme.bodyLarge?.copyWith(
//                                       color: theme.colorScheme.onSurface.withOpacity(0.6),
//                                     ),
//                                   ),
//                                 ];
//                               );
//                             },
//                             loading: () => const CircularProgressIndicator(),
//                             error: (error, stack) => Text('Error: $error'),
//                           ),
                          
//                           const SizedBox(height: AppTheme.spacing32),
//                         ],
//                       ),
//                     ),
//                   ),
                  
//                   // Bottom Padding
//                   const SliverToBoxAdapter(
//                     child: SizedBox(height: 100),
//                   ),
//                 ],
//               ),
              
//               // Bottom CTA
//               Positioned(
//                 bottom: 0,
//                 left: 0,
//                 right: 0,
//                 child: Container(
//                   padding: const EdgeInsets.all(AppTheme.spacing20),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.bottomCenter,
//                       end: Alignment.topCenter,
//                       colors: [
//                         theme.scaffoldBackgroundColor,
//                         theme.scaffoldBackgroundColor.withOpacity(0.9),
//                         theme.scaffoldBackgroundColor.withOpacity(0),
//                       ],
//                     ),
//                   ),
//                   child: ElevatedButton(
//                     onPressed: _isLoading ? null : _startTrial,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppTheme.primaryColor,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(
//                         vertical: AppTheme.spacing16,
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(AppTheme.radius12),
//                       ),
//                     ),
//                     child: _isLoading
//                         ? const SizedBox(
//                             height: 20,
//                             width: 20,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                             ),
//                           )
//                         : const Text(
//                             'Start 7-Day Free Trial',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                   ),
//                 ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.2),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   } }