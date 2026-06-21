import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../pages/login_page.dart';
import '../pages/register_page.dart';
import '../services/auth_service.dart';
import '../../home/pages/home_placeholder_page.dart';
import '../../../core/styles/design_tokens.dart';

bool _looksLikeEmail(String value) {
  final atIndex = value.indexOf('@');
  if (atIndex <= 0 || atIndex == value.length - 1) {
    return false;
  }
  final domain = value.substring(atIndex + 1);
  final dotIndex = domain.lastIndexOf('.');
  if (dotIndex <= 0 || dotIndex == domain.length - 1) {
    return false;
  }
  return !value.contains(' ') && !domain.contains(' ');
}

class AuthHeader extends StatelessWidget {
  final bool isDesktop;
  final String title;
  final String subtitle;

  const AuthHeader({
    super.key,
    required this.isDesktop,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isDesktop
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        if (!isDesktop) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  color: DesignColors.freshGreen,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: const Icon(
                  Icons.sports_tennis_rounded,
                  color: DesignColors.ink,
                  size: 24.0,
                ),
              ),
              const SizedBox(width: 8.0),
              const Text(
                'RallyHub',
                style: TextStyle(
                  color: DesignColors.ink,
                  fontSize: 24.0,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
        ],
        Text(
          title,
          textAlign: isDesktop ? TextAlign.left : TextAlign.center,
          style: TextStyle(
            color: DesignColors.ink,
            fontSize: isDesktop ? 36.0 : 28.0,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 6.0),
        Text(
          subtitle,
          textAlign: isDesktop ? TextAlign.left : TextAlign.center,
          style: TextStyle(
            color: DesignColors.muted,
            fontSize: isDesktop ? 16.0 : 14.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class AuthLoginForm extends StatefulWidget {
  const AuthLoginForm({super.key});

  @override
  State<AuthLoginForm> createState() => _AuthLoginFormState();
}

class _AuthLoginFormState extends State<AuthLoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  DateTime? _retryAfter;
  final _authService = AuthService();

  bool get _isRateLimited =>
      _retryAfter != null && DateTime.now().isBefore(_retryAfter!);

  Future<void> _submit() async {
    if (_isLoading || _isRateLimited || !_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await _authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      debugPrint('Login completed. session=${response.session != null}');
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomePlaceholderPage()),
        (route) => false,
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_friendlyAuthError(e.message)),
          backgroundColor: Colors.redAccent,
        ),
      );
      if (e.message.contains('Too Many Requests') ||
          e.message.contains('429')) {
        setState(() {
          _retryAfter = DateTime.now().add(const Duration(seconds: 30));
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not log in. Check your connection and try again.',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = !_isLoading && !_isRateLimited;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email Field
          const Text(
            'Email',
            style: TextStyle(
              color: DesignColors.courtGreen,
              fontSize: 14.0,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8.0),
          TextFormField(
            controller: _emailController,
            autofillHints: const [AutofillHints.email],
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: 'name@example.com',
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14.0),
              prefixIcon: const Icon(
                Icons.email_outlined,
                color: DesignColors.muted,
                size: 20.0,
              ),
              filled: true,
              fillColor: const Color(0xFFFFFFF4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!_looksLikeEmail(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 20.0),

          // Password Field
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Password',
                style: TextStyle(
                  color: DesignColors.courtGreen,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox.shrink(),
            ],
          ),
          const SizedBox(height: 8.0),
          TextFormField(
            controller: _passwordController,
            autofillHints: const [AutofillHints.password],
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              hintText: 'Enter password',
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14.0),
              prefixIcon: const Icon(
                Icons.lock_outlined,
                color: DesignColors.muted,
                size: 20.0,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: DesignColors.muted,
                  size: 20.0,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              filled: true,
              fillColor: const Color(0xFFFFFFF4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 22.0),

          // Login Button
          SizedBox(
            height: 56.0,
            child: ElevatedButton(
              onPressed: canSubmit ? _submit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignColors.freshGreen,
                foregroundColor: DesignColors.ink,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22.0,
                      height: 22.0,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: DesignColors.ink,
                      ),
                    )
                  : const Text(
                      'Log in',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0,
                      ),
                    ),
            ),
          ),
          if (_isRateLimited) ...[
            const SizedBox(height: 12.0),
            Text(
              'Too many login attempts. Please wait 30 seconds and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.redAccent.shade200,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _friendlyAuthError(String message) {
    if (message.contains('Too Many Requests') || message.contains('429')) {
      return 'Too many login attempts right now. Please wait a bit and try again.';
    }
    return message;
  }
}

class AuthRegisterForm extends StatefulWidget {
  const AuthRegisterForm({super.key});

  @override
  State<AuthRegisterForm> createState() => _AuthRegisterFormState();
}

class _AuthRegisterFormState extends State<AuthRegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  DateTime? _retryAfter;
  final _authService = AuthService();

  bool get _isRateLimited =>
      _retryAfter != null && DateTime.now().isBefore(_retryAfter!);

  Future<void> _submit() async {
    if (_isLoading || _isRateLimited || !_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await _authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _nameController.text.trim(),
      );
      if (!mounted) return;
      debugPrint('Signup completed. session=${response.session != null}');
      if (response.session != null) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomePlaceholderPage()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created. Confirm your email, then log in.'),
            duration: Duration(seconds: 5),
            backgroundColor: DesignColors.courtGreen,
          ),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_friendlyAuthError(e.message)),
          backgroundColor: Colors.redAccent,
        ),
      );
      if (e.message.contains('Too Many Requests') ||
          e.message.contains('429')) {
        setState(() {
          _retryAfter = DateTime.now().add(const Duration(seconds: 30));
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not create the account. Try again.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = !_isLoading && !_isRateLimited;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Name Field
          const Text(
            'Full Name',
            style: TextStyle(
              color: DesignColors.courtGreen,
              fontSize: 14.0,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8.0),
          TextFormField(
            controller: _nameController,
            autofillHints: const [AutofillHints.name],
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: 'John Doe',
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14.0),
              prefixIcon: const Icon(
                Icons.person_outline,
                color: DesignColors.muted,
                size: 20.0,
              ),
              filled: true,
              fillColor: const Color(0xFFFFFFF4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),

          // Email Field
          const Text(
            'Email',
            style: TextStyle(
              color: DesignColors.courtGreen,
              fontSize: 14.0,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8.0),
          TextFormField(
            controller: _emailController,
            autofillHints: const [AutofillHints.email],
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: 'name@example.com',
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14.0),
              prefixIcon: const Icon(
                Icons.email_outlined,
                color: DesignColors.muted,
                size: 20.0,
              ),
              filled: true,
              fillColor: const Color(0xFFFFFFF4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!_looksLikeEmail(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),

          // Password Field
          const Text(
            'Password',
            style: TextStyle(
              color: DesignColors.courtGreen,
              fontSize: 14.0,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8.0),
          TextFormField(
            controller: _passwordController,
            autofillHints: const [AutofillHints.newPassword],
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: 'Enter password',
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14.0),
              prefixIcon: const Icon(
                Icons.lock_outlined,
                color: DesignColors.muted,
                size: 20.0,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: DesignColors.muted,
                  size: 20.0,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              filled: true,
              fillColor: const Color(0xFFFFFFF4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),

          // Confirm Password Field
          const Text(
            'Confirm Password',
            style: TextStyle(
              color: DesignColors.courtGreen,
              fontSize: 14.0,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8.0),
          TextFormField(
            controller: _confirmPasswordController,
            autofillHints: const [AutofillHints.newPassword],
            obscureText: _obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              hintText: 'Confirm password',
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14.0),
              prefixIcon: const Icon(
                Icons.lock_outlined,
                color: DesignColors.muted,
                size: 20.0,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: DesignColors.muted,
                  size: 20.0,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
              filled: true,
              fillColor: const Color(0xFFFFFFF4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: 22.0),

          // Register Button
          SizedBox(
            height: 56.0,
            child: ElevatedButton(
              onPressed: canSubmit ? _submit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignColors.freshGreen,
                foregroundColor: DesignColors.ink,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22.0,
                      height: 22.0,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: DesignColors.ink,
                      ),
                    )
                  : const Text(
                      'Create account',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0,
                      ),
                    ),
            ),
          ),
          if (_isRateLimited) ...[
            const SizedBox(height: 12.0),
            Text(
              'Too many signup attempts. Please wait 30 seconds and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.redAccent.shade200,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _friendlyAuthError(String message) {
    if (message.contains('Too Many Requests') || message.contains('429')) {
      return 'Too many signup attempts right now. Please wait a bit and try again.';
    }
    return message;
  }
}

class SocialLogins extends StatelessWidget {
  const SocialLogins({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFF4),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: DesignColors.muted.withValues(alpha: 0.2)),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.lock_outline_rounded,
            color: DesignColors.courtGreen,
            size: 20.0,
          ),
          SizedBox(width: 10.0),
          Expanded(
            child: Text(
              'Secure email sign-in with Supabase Auth',
              style: TextStyle(
                color: DesignColors.courtGreen,
                fontSize: 13.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthRegisterFooter extends StatelessWidget {
  const AuthRegisterFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text(
          "Don't have an account?",
          style: TextStyle(
            color: DesignColors.muted,
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 4.0),
        GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const RegisterPage()),
            );
          },
          child: const Text(
            'Create account',
            style: TextStyle(
              color: DesignColors.courtGreen,
              fontWeight: FontWeight.w700,
              fontSize: 14.0,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}

class AuthLoginFooter extends StatelessWidget {
  const AuthLoginFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text(
          "Already have an account?",
          style: TextStyle(
            color: DesignColors.muted,
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 4.0),
        GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          },
          child: const Text(
            'Log In',
            style: TextStyle(
              color: DesignColors.courtGreen,
              fontWeight: FontWeight.w700,
              fontSize: 14.0,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
