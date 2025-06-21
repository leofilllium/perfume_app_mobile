import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:perfume_app_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:perfume_app_mobile/features/auth/presentation/pages/auth_page.dart';
import 'package:perfume_app_mobile/features/perfume/domain/entities/perfume.dart';
import 'package:perfume_app_mobile/features/perfume/presentation/bloc/order/order_bloc.dart';
import 'package:perfume_app_mobile/features/perfume/presentation/bloc/order/order_event.dart';
import 'package:perfume_app_mobile/features/perfume/presentation/bloc/order/order_state.dart';
import 'package:perfume_app_mobile/features/perfume/presentation/bloc/recommendation/recommendation_bloc.dart';
import 'package:perfume_app_mobile/features/perfume/presentation/bloc/recommendation/recommendation_event.dart';
import 'package:perfume_app_mobile/features/perfume/presentation/bloc/recommendation/recommendation_state.dart';
import 'package:perfume_app_mobile/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:perfume_app_mobile/features/profile/presentation/bloc/profile_event.dart';
import '../widgets/order_modal.dart';
import '../widgets/perfume_card.dart';

class ForYouPage extends StatefulWidget {
  const ForYouPage({Key? key}) : super(key: key);

  @override
  State<ForYouPage> createState() => _ForYouPageState();
}

class _ForYouPageState extends State<ForYouPage> {
  int _currentPage = 1;
  final int _pageSize = 10;
  final ScrollController _scrollController = ScrollController();

  // For the order modal
  Perfume? _selectedPerfumeForOrder;
  String? _orderErrorMessage;
  bool _isOrderLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchRecommendedPerfumes();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _onScrollToEnd();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _fetchRecommendedPerfumes({bool isRefresh = false}) {
    if (isRefresh) {
      _currentPage = 1;
    }
    BlocProvider.of<RecommendationBloc>(context).add(GetRecommendedPerfumesEvent(
      page: _currentPage,
      pageSize: _pageSize,
    ));
  }

  void _onScrollToEnd() {
  final state = BlocProvider.of<RecommendationBloc>(context).state;
    if (state is RecommendedPerfumesLoaded && !state.hasReachedMax && !state.isFetchingMore) {
      _currentPage++;
      _fetchRecommendedPerfumes();
    }
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
                  SnackBar(content: Text(state.message)),
                );
                // Optionally, refetch recommendations after successful order if desired
                // _fetchRecommendedPerfumes(isRefresh: true);
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
                    BlocProvider.of<OrderBloc>(context).add(PlaceOrderEvent(
                      orderedPerfume: _selectedPerfumeForOrder!,
                      quantity: quantity,
                      orderMessage: message,
                    ));
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

  void _handleQuizRedirect() {
    // Navigator.of(context).push(
    //   MaterialPageRoute(builder: (context) => const QuizPage()),
    // );
  }

  void _navigateToAuthPage(BuildContext context) async {
    // Navigate to AuthPage and wait for it to pop back
    final authBloc = BlocProvider.of<AuthBloc>(context);
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (routeContext) =>
            BlocProvider
                .value( // Use BlocProvider.value to pass existing AuthBloc
              value: authBloc,
              child: AuthPage(
                onAuthSuccess: () {
                  // Pop the AuthPage when authentication is successful
                  Navigator.of(routeContext).pop(true);
                },
              ),
            ),
      ),
    );

    // After AuthPage pops, re-fetch profile data to update UI
    if (result == true) { // result might be null if popped via back button
      BlocProvider.of<ProfileBloc>(context).add(GetProfileDataEvent());
    }
  }

  void _handleLoginRedirect() {
    _navigateToAuthPage(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'For You',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<RecommendationBloc, RecommendationState>(
        listener: (context, state) {
          if (state is RecommendationError && state.message == UNAUTHORIZED_RECOMMENDATIONS_MESSAGE) {
            // Handle unauthorized access specifically for recommendations
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            _handleLoginRedirect();
          }
        },
        builder: (context, state) {
          if (state is RecommendedPerfumesLoading) {
            return const Center(child: CupertinoActivityIndicator());
          } else if (state is QuizNotCompletedState) {
            return _buildQuizPrompt();
          } else if (state is RecommendedPerfumesLoaded) {
            if (state.perfumeList.perfumes.isEmpty) {
              return const Center(
                child: Text(
                  'No personalized recommendations found at the moment.',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                _fetchRecommendedPerfumes(isRefresh: true);
              },
              child: GridView.builder(
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
                      onOrderClick: () => _showOrderModal(perfume),
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
              ),
            );
          } else if (state is RecommendationError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            );
          }
          return const Center(
            child: Text(
              'Welcome! Your personalized recommendations will appear here.',
              style: TextStyle(color: Colors.grey, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuizPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.quiz_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            const Text(
              'Complete your preference quiz to get personalized recommendations.',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _handleQuizRedirect,
              icon: const Icon(Icons.rate_review_outlined),
              label: const Text('Complete the Quiz', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown.shade400,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}