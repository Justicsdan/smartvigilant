class VigilantVerifyEmail extends StatelessWidget {
  final String email;

  const VigilantVerifyEmail({required this.email, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: vigilantPrimary),
          onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mark_email_read_outlined, size: 120, color: vigilantAccent),
            SizedBox(height: 40),
            Text(
              "Check Your Email",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              "We've sent a verification link to:",
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              email,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: vigilantPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            Text(
              "Click the link in the email to activate your account.\nIt expires in 24 hours.",
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
              icon: Icon(Icons.login),
              label: Text("Back to Login"),
              style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () {
                // Optional: Resend verification email
              },
              child: Text("Didn't receive it? Resend email"),
            ),
          ],
        ),
      ),
    );
  }
}
