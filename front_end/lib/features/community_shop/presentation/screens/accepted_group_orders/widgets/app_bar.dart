import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/widgets/icons/icon_with_container.dart';
import 'package:semo/features/community_shop/presentation/screens/widgets/icon_button.dart';
import 'package:semo/features/message/routes/const.dart';
import 'package:flutter/cupertino.dart';

PreferredSizeWidget buildAppBar(BuildContext context) => AppBar(
      centerTitle: true,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      title: const Text('Vos livraisons'),
      actions: [
        buildIcon(
          iconColor: Colors.white,
          backgroundColor: Colors.green,
          icon: CupertinoIcons.chat_bubble_text_fill,
          onPressed: () {
            context.pushNamed(MessageRoutesConstants.message);
          },
        ),
        const SizedBox(width: 16),
      ],
      leading: IconButton(
        icon: buildIconButton(Icons.close, Colors.black, Colors.white),
        onPressed: () => context.pop(),
      ),
    );
