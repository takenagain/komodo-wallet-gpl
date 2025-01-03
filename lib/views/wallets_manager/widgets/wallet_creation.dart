import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web_dex/blocs/blocs.dart';
import 'package:web_dex/generated/codegen_loader.g.dart';
import 'package:web_dex/model/wallets_manager_models.dart';
import 'package:komodo_ui_kit/komodo_ui_kit.dart';

import 'package:web_dex/shared/utils/utils.dart';
import 'package:web_dex/shared/widgets/disclaimer/eula_tos_checkboxes.dart';
import 'package:web_dex/views/wallets_manager/widgets/creation_password_fields.dart';

class WalletCreation extends StatefulWidget {
  const WalletCreation({
    Key? key,
    required this.action,
    required this.onCreate,
    required this.onCancel,
  }) : super(key: key);

  final WalletsManagerAction action;
  final void Function({
    required String name,
    required String password,
    required String seed,
  }) onCreate;
  final void Function() onCancel;

  @override
  State<WalletCreation> createState() => _WalletCreationState();
}

class _WalletCreationState extends State<WalletCreation> {
  final TextEditingController _nameController = TextEditingController(text: '');
  final TextEditingController _passwordController =
      TextEditingController(text: '');
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _eulaAndTosChecked = false;
  bool _inProgress = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.action == WalletsManagerAction.create
                ? LocaleKeys.walletCreationTitle.tr()
                : LocaleKeys.walletImportTitle.tr(),
            style:
                Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 24),
          _buildFields(),
          const SizedBox(height: 22),
          EulaTosCheckboxes(
            key: const Key('create-wallet-eula-checks'),
            isChecked: _eulaAndTosChecked,
            onCheck: (isChecked) {
              setState(() {
                _eulaAndTosChecked = isChecked;
              });
            },
          ),
          const SizedBox(height: 32),
          UiPrimaryButton(
            key: const Key('confirm-password-button'),
            height: 50,
            text: _inProgress
                ? '${LocaleKeys.pleaseWait.tr()}...'
                : LocaleKeys.create.tr(),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            onPressed: _isCreateButtonEnabled ? _onCreate : null,
          ),
          const SizedBox(height: 20),
          UiUnderlineTextButton(
            onPressed: widget.onCancel,
            text: LocaleKeys.cancel.tr(),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget _buildFields() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildNameField(),
        const SizedBox(height: 20),
        const UiDivider(),
        const SizedBox(height: 20),
        CreationPasswordFields(
          passwordController: _passwordController,
          onFieldSubmitted: (_) {
            if (_isCreateButtonEnabled) _onCreate();
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildNameField() {
    return UiTextFormField(
      key: const Key('name-wallet-field'),
      controller: _nameController,
      autofocus: true,
      autocorrect: false,
      textInputAction: TextInputAction.next,
      enableInteractiveSelection: true,
      validator: (String? name) =>
          _inProgress ? null : walletsBloc.validateWalletName(name ?? ''),
      inputFormatters: [LengthLimitingTextInputFormatter(40)],
      hintText: LocaleKeys.walletCreationNameHint.tr(),
    );
  }

  void _onCreate() {
    if (!_eulaAndTosChecked) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _inProgress = true);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final String seed = generateSeed();

      widget.onCreate(
        name: _nameController.text,
        password: _passwordController.text,
        seed: seed,
      );
    });
  }

  bool get _isCreateButtonEnabled => _eulaAndTosChecked && !_inProgress;
}