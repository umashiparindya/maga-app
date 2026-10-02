import 'package:flutter/material.dart';

import 'application/recommendation_controller.dart';
import 'core/app_identity.dart';
import 'core/app_routes.dart';
import 'core/app_theme.dart';
import 'data/destination_repository.dart';
import 'data/local_destination_repository.dart';
import 'domain/recommendation_engine.dart';

class MashiApp extends StatefulWidget {
  const MashiApp({this.repository, this.engine, super.key});

  final DestinationRepository? repository;
  final RecommendationEngine? engine;

  @override
  State<MashiApp> createState() => _MashiAppState();
}

class _MashiAppState extends State<MashiApp> {
  late final DestinationRepository _repository;
  late final RecommendationController _controller;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? LocalDestinationRepository();
    _controller = RecommendationController(
      repository: _repository,
      engine: widget.engine,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppIdentity.productName,
      theme: MashiTheme.light,
      initialRoute: AppRoutes.welcome,
      routes: AppRoutes.routesFor(_controller, repository: _repository),
    );
  }
}
