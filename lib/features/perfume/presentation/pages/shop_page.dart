import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:perfume_app_mobile/features/perfume/domain/entities/perfume.dart';
import 'package:perfume_app_mobile/features/perfume/presentation/bloc/order/order_bloc.dart';
import 'package:perfume_app_mobile/features/perfume/presentation/bloc/order/order_event.dart';
import 'package:perfume_app_mobile/features/perfume/presentation/bloc/order/order_state.dart';
import '../bloc/perfume/perfume_bloc.dart';
import '../bloc/perfume/perfume_event.dart';
import '../bloc/perfume/perfume_state.dart';
import '../widgets/order_modal.dart';
import '../widgets/perfume_card.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({Key? key}) : super(key: key);

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  String? _genderFilter;
  final TextEditingController _searchQueryController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  int _currentPage = 1;
  final int _pageSize = 10;

  // Scroll controller for infinite scrolling
  final ScrollController _scrollController = ScrollController();

  // For the order modal
  Perfume? _selectedPerfumeForOrder; // Hold the selected Perfume object
  String? _orderErrorMessage;
  bool _isOrderLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchPerfumes(); // Initial load

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        // User has scrolled to the bottom
        _onScrollToEnd();
      }
    });
  }

  @override
  void dispose() {
    _searchQueryController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _fetchPerfumes({bool isRefresh = false}) {
    if (isRefresh) {
      _currentPage = 1;
    }
    BlocProvider.of<PerfumeBloc>(context).add(GetPerfumesEvent(
      gender: _genderFilter,
      searchQuery: _searchQueryController.text,
      minPrice: double.tryParse(_minPriceController.text),
      maxPrice: double.tryParse(_maxPriceController.text),
      page: _currentPage,
      pageSize: _pageSize,
    ));
  }

  void _onScrollToEnd() {
    final state = BlocProvider.of<PerfumeBloc>(context).state;
    if (state is AllPerfumesLoaded && !state.hasReachedMax && !state.isFetchingMore) {
      _currentPage++;
      _fetchPerfumes();
    }
  }

  // Changed to accept Perfume object
  void _showOrderModal(Perfume perfume) {
    setState(() {
      _selectedPerfumeForOrder = perfume; // Store the full perfume object
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
                // Dismiss the modal
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
                // Ensure _isOrderLoading is reset to false
                setState(() {
                  _isOrderLoading = false;
                });
                // No need to call _fetchPerfumes(isRefresh: true); as per user request
                // The perfume list will NOT refresh here.
              } else if (state is OrderError) {
                // If there's an error, keep the modal open and display the message
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
                    BlocProvider.of<OrderBloc>(context).add(PlaceOrderEvent(
                      orderedPerfume: _selectedPerfumeForOrder!,
                      quantity: quantity,
                      orderMessage: message,
                    ));
                  }
                },
                onCancel: () {
                  // Dismiss the modal on cancel
                  Navigator.of(context).pop();
                  setState(() {
                    _selectedPerfumeForOrder = null; // Clear selected perfume
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Explore Scents',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              children: [
                // Gender Filter Chips
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildFilterChip('All', null),
                    _buildFilterChip('Female', 'FEMALE'),
                    _buildFilterChip('Male', 'MALE'),
                    _buildFilterChip('Unisex', 'UNISEX'),
                  ],
                ),
                const SizedBox(height: 16),
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchQueryController,
                    decoration: const InputDecoration(
                      hintText: 'Search perfumes...',
                      hintStyle: TextStyle(color: Colors.grey),
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _currentPage = 1;
                      });
                      _fetchPerfumes();
                    },
                  ),
                ),
                const SizedBox(height: 12),
                // Price Range
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _minPriceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: 'Min',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _currentPage = 1;
                            });
                            _fetchPerfumes();
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _maxPriceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: 'Max',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _currentPage = 1;
                            });
                            _fetchPerfumes();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Products Grid
          Expanded(
            child: BlocBuilder<PerfumeBloc, PerfumeState>(
              builder: (context, state) {
                if (state is AllPerfumesLoading) {
                  return const Center(child: CupertinoActivityIndicator());
                } else if (state is AllPerfumesLoaded) {
                  if (state.perfumeList.perfumes.isEmpty) {
                    return const Center(
                      child: Text(
                        'No perfumes found matching your criteria.',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    );
                  }
                  return GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16.0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: state.perfumeList.perfumes.length + (state.isFetchingMore ? 2 : 0),
                    itemBuilder: (context, index) {
                      if (index < state.perfumeList.perfumes.length) {
                        final perfume = state.perfumeList.perfumes[index];
                        return PerfumeCard(
                          perfume: perfume,
                          onOrderClick: () => _showOrderModal(perfume), // Pass the full perfume object
                        );
                      } else {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CupertinoActivityIndicator(),
                          ),
                        );
                      }
                    },
                  );
                } else if (state is PerfumeError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  );
                }
                return const Center(
                  child: Text(
                    'Select filters to explore perfumes.',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? filterValue) {
    final isSelected = _genderFilter == filterValue;
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? Colors.black87 : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? Colors.black87 : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _genderFilter = filterValue;
            _currentPage = 1;
          });
          _fetchPerfumes(isRefresh: true);
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade600,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
