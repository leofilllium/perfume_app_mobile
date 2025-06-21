import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:perfume_app_mobile/features/perfume/domain/entities/perfume.dart';
import 'package:perfume_app_mobile/features/perfume/presentation/bloc/order/order_bloc.dart';
import 'package:perfume_app_mobile/features/perfume/presentation/bloc/order/order_event.dart';
import 'package:perfume_app_mobile/features/perfume/presentation/bloc/order/order_state.dart';
import 'package:perfume_app_mobile/features/perfume/presentation/bloc/perfume/perfume_state.dart';
import 'package:perfume_app_mobile/features/perfume/presentation/widgets/perfume_image.dart';
import '../bloc/perfume/perfume_bloc.dart';
import '../bloc/perfume/perfume_event.dart';
import '../widgets/order_modal.dart';

class PerfumeDetailsPage extends StatefulWidget {
  final int perfumeId;

  const PerfumeDetailsPage({
    Key? key,
    required this.perfumeId,
  }) : super(key: key);

  @override
  State<PerfumeDetailsPage> createState() => _PerfumeDetailsPageState();
}

class _PerfumeDetailsPageState extends State<PerfumeDetailsPage> {
  // For the order modal
  Perfume? _selectedPerfumeForOrder;
  String? _orderErrorMessage;
  bool _isOrderLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchPerfumeDetails();
  }

  void _fetchPerfumeDetails() {
    BlocProvider.of<PerfumeBloc>(context).add(
      GetPerfumeDetailsEvent(id: widget.perfumeId),
    );
  }

  void _showOrderModal(Perfume perfume) {
    setState(() {
      _selectedPerfumeForOrder = perfume;
      _orderErrorMessage = null;
      _isOrderLoading = false;
    });

    final orderBloc = BlocProvider.of<OrderBloc>(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BlocProvider.value(
          value: orderBloc,
          child: BlocConsumer<OrderBloc, OrderState>(
            listener: (context, state) {
              if (state is OrderSuccess) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green,
                  ),
                );
                setState(() {
                  _isOrderLoading = false;
                });
              } else if (state is OrderError) {
                setState(() {
                  _orderErrorMessage = state.message;
                  _isOrderLoading = false;
                });
              } else if (state is OrderPlacing) {
                setState(() {
                  _isOrderLoading = true;
                });
              }
            },
            builder: (context, state) {
              return OrderModal(
                onSubmit: (quantity, message) {
                  if (_selectedPerfumeForOrder != null) {
                    BlocProvider.of<OrderBloc>(context).add(
                      PlaceOrderEvent(
                        orderedPerfume: _selectedPerfumeForOrder!,
                        quantity: quantity,
                        orderMessage: message,
                      ),
                    );
                  }
                },
                onCancel: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _selectedPerfumeForOrder = null;
                    _orderErrorMessage = null;
                    _isOrderLoading = false;
                  });
                },
                errorMessage: _orderErrorMessage,
                isLoading: _isOrderLoading,
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: BlocBuilder<PerfumeBloc, PerfumeState>(
        builder: (context, state) {
          if (state is PerfumeDetailsLoading) {
            return const Center(child: CupertinoActivityIndicator(radius: 20));
          } else if (state is PerfumeDetailsLoaded) {
            return _buildPerfumeDetails(state.perfume);
          } else if (state is PerfumeError) {
            return _buildErrorState(state.message);
          }
          return const Center(
            child: Text(
              'Something went wrong',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: Colors.red, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _fetchPerfumeDetails,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black87,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildPerfumeDetails(Perfume perfume) {
    return CustomScrollView(
      slivers: [
        // Custom App Bar with Image
        SliverAppBar(
          expandedHeight: 400,
          pinned: true,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.grey[100]!,
                    Colors.white,
                  ],
                ),
              ),
              child: perfume.image != null
                  ? PerfumeImage(imageData: perfume.image)
                  : _buildPlaceholderImage(),
            ),
          ),
        ),
        // Content
        SliverToBoxAdapter(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Info
                  _buildHeaderSection(perfume),
                  const SizedBox(height: 24),

                  // Price and Stock
                  _buildPriceSection(perfume),
                  const SizedBox(height: 24),

                  // Rating and Reviews
                  _buildRatingSection(perfume),
                  const SizedBox(height: 32),

                  // Description
                  _buildDescriptionSection(perfume),
                  const SizedBox(height: 32),

                  // Fragrance Notes
                  _buildFragranceNotesSection(perfume),
                  const SizedBox(height: 32),

                  // Details
                  _buildDetailsSection(perfume),
                  const SizedBox(height: 32),

                  // Performance Metrics
                  _buildPerformanceSection(perfume),
                  const SizedBox(height: 40),

                  // Order Button
                  _buildOrderButton(perfume),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[200]!,
            Colors.grey[300]!,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.ac_unit_sharp,
          size: 80,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(Perfume perfume) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          perfume.brand,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          perfume.name,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildInfoChip(perfume.gender, Icons.person),
            const SizedBox(width: 8),
            _buildInfoChip('${perfume.size}ml', Icons.opacity),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection(Perfume perfume) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '\$${perfume.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              'In stock: ${perfume.stock}',
              style: TextStyle(
                fontSize: 14,
                color: perfume.stock > 0 ? Colors.green[600] : Colors.red[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingSection(Perfume perfume) {
    return Row(
      children: [
        Row(
          children: List.generate(5, (index) {
            return Icon(
              index < perfume.averageRating.floor()
                  ? Icons.star
                  : index < perfume.averageRating
                  ? Icons.star_half
                  : Icons.star_border,
              color: Colors.amber,
              size: 20,
            );
          }),
        ),
        const SizedBox(width: 8),
        Text(
          '${perfume.averageRating.toStringAsFixed(1)}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '(${perfume.totalReviews} reviews)',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(Perfume perfume) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          perfume.description,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildFragranceNotesSection(Perfume perfume) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fragrance Notes',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        _buildNotesCategory('Top Notes', perfume.topNotes, Colors.blue[100]!),
        const SizedBox(height: 12),
        _buildNotesCategory('Middle Notes', perfume.middleNotes, Colors.purple[100]!),
        const SizedBox(height: 12),
        _buildNotesCategory('Base Notes', perfume.baseNotes, Colors.orange[100]!),
      ],
    );
  }

  Widget _buildNotesCategory(String title, List<String> notes, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: notes.map((note) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              note,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildDetailsSection(Perfume perfume) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        _buildDetailRow('Fragrance Family', perfume.fragranceFamily),
        _buildDetailRow('Season', perfume.season),
        _buildDetailRow('Occasion', perfume.occasion),
        _buildDetailRow('Intensity', perfume.intensity),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceSection(Perfume perfume) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Performance',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        _buildPerformanceMetric('Longevity', perfume.longevity, 10),
        const SizedBox(height: 12),
        _buildPerformanceMetric('Sillage', perfume.sillage, 10),
      ],
    );
  }

  Widget _buildPerformanceMetric(String label, int value, int maxValue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            Text(
              '$value/$maxValue',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: value / maxValue,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(Colors.black87),
        ),
      ],
    );
  }

  Widget _buildOrderButton(Perfume perfume) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: perfume.stock > 0 ? () => _showOrderModal(perfume) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black87,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey[300],
          disabledForegroundColor: Colors.grey[500],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Text(
          perfume.stock > 0 ? 'Place an Order' : 'Out of Stock',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}