import 'package:flutter/material.dart';

import '../data/role_repository.dart';
import '../models/role_model.dart';
import 'role_card_screen.dart';

class RoleAssistantScreen extends StatelessWidget {
  const RoleAssistantScreen({super.key});

  void _openRole(BuildContext context, RoleModel role) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RoleCardScreen(role: role),
      ),
    );
  }

  Widget _buildRoleTile(
    BuildContext context, {
    required RoleModel role,
  }) {
    return Material(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _openRole(context, role),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                role.icon,
                style: const TextStyle(fontSize: 22),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    role.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Role Assistant'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: FutureBuilder<List<RoleModel>>(
          future: RoleRepository().loadRoles(),
          builder:
              (BuildContext context, AsyncSnapshot<List<RoleModel>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Failed to load roles: ${snapshot.error}'),
              );
            }

            final List<RoleModel> roles = snapshot.data ?? const <RoleModel>[];
            if (roles.isEmpty) {
              return const Center(child: Text('No roles found.'));
            }

            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final bool isLandscape =
                      constraints.maxWidth > constraints.maxHeight;
                  final int crossAxisCount = isLandscape ? 4 : 2;
                  const double spacing = 12;

                  final double width = constraints.maxWidth;
                  final double height = constraints.maxHeight;
                  final int rows = (roles.length / crossAxisCount).ceil();

                  final double tileWidth =
                      (width - spacing * (crossAxisCount - 1)) / crossAxisCount;
                  final double tileHeight =
                      (height - spacing * (rows - 1)) / rows;
                  final double childAspectRatio = tileWidth / tileHeight;

                  return GridView.builder(
                    itemCount: roles.length,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: spacing,
                      mainAxisSpacing: spacing,
                      childAspectRatio: childAspectRatio,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      final RoleModel role = roles[index];
                      return _buildRoleTile(context, role: role);
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
