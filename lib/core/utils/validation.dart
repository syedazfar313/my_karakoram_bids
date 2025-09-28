class ValidationUtils {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    value = value.trim();

    // Basic email regex
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    // Additional checks
    if (value.length > 254) {
      return 'Email address is too long';
    }

    return null;
  }

  // Phone validation (Pakistani format)
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    value = value.trim().replaceAll(' ', '').replaceAll('-', '');

    // Pakistani mobile formats: 03XXXXXXXXX or +923XXXXXXXXX
    final phoneRegex = RegExp(r'^(03|(\+92)?3)\d{9}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid Pakistani mobile number\n(e.g., 03XXXXXXXXX)';
    }

    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    if (value.length > 50) {
      return 'Password is too long (max 50 characters)';
    }

    // Check for at least one letter and one number (optional but recommended)
    // if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)').hasMatch(value)) {
    //   return 'Password must contain at least one letter and one number';
    // }

    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(
    String? value,
    String? originalPassword,
  ) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != originalPassword) {
      return 'Passwords do not match';
    }

    return null;
  }

  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }

    value = value.trim();

    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }

    if (value.length > 50) {
      return 'Name is too long (max 50 characters)';
    }

    // Only allow letters, spaces, and common name characters
    if (!RegExp(r"^[a-zA-Z\s\-\.\']+$").hasMatch(value)) {
      return 'Name can only contain letters, spaces, hyphens, and apostrophes';
    }

    return null;
  }

  // Project title validation
  static String? validateProjectTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Project title is required';
    }

    value = value.trim();

    if (value.length < 5) {
      return 'Project title must be at least 5 characters';
    }

    if (value.length > 100) {
      return 'Project title is too long (max 100 characters)';
    }

    return null;
  }

  // Description validation
  static String? validateDescription(
    String? value, {
    int minLength = 10,
    int maxLength = 500,
  }) {
    if (value == null || value.trim().isEmpty) {
      return 'Description is required';
    }

    value = value.trim();

    if (value.length < minLength) {
      return 'Description must be at least $minLength characters';
    }

    if (value.length > maxLength) {
      return 'Description is too long (max $maxLength characters)';
    }

    return null;
  }

  // Location validation
  static String? validateLocation(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Location is required';
    }

    value = value.trim();

    if (value.length < 2) {
      return 'Location must be at least 2 characters';
    }

    if (value.length > 100) {
      return 'Location is too long (max 100 characters)';
    }

    return null;
  }

  // Budget validation
  static String? validateBudget(String? value, {bool required = false}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Budget is required' : null;
    }

    value = value
        .trim()
        .replaceAll(',', '')
        .replaceAll('PKR', '')
        .replaceAll('Rs', '')
        .trim();

    final budget = double.tryParse(value);
    if (budget == null) {
      return 'Please enter a valid budget amount';
    }

    if (budget < 0) {
      return 'Budget cannot be negative';
    }

    if (budget > 100000000) {
      // 10 crore
      return 'Budget amount is too high';
    }

    if (budget > 0 && budget < 1000) {
      // Less than 1000 PKR
      return 'Budget amount seems too low';
    }

    return null;
  }

  // Bid amount validation
  static String? validateBidAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Bid amount is required';
    }

    value = value.trim().replaceAll(',', '');

    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Please enter a valid amount';
    }

    if (amount <= 0) {
      return 'Bid amount must be greater than zero';
    }

    if (amount > 50000000) {
      // 5 crore
      return 'Bid amount seems too high';
    }

    if (amount < 1000) {
      // Less than 1000 PKR
      return 'Bid amount seems too low';
    }

    return null;
  }

  // Duration validation
  static String? validateDuration(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Duration is required';
    }

    final days = int.tryParse(value.trim());
    if (days == null) {
      return 'Please enter a valid number of days';
    }

    if (days <= 0) {
      return 'Duration must be at least 1 day';
    }

    if (days > 3650) {
      // 10 years
      return 'Duration seems too long (max 10 years)';
    }

    return null;
  }

  // Experience validation
  static String? validateExperience(String? value, {bool required = false}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Experience is required' : null;
    }

    value = value.trim();

    if (value.length > 200) {
      return 'Experience description is too long (max 200 characters)';
    }

    return null;
  }

  // Comment validation
  static String? validateComment(String? value, {bool required = false}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Comment is required' : null;
    }

    value = value.trim();

    if (required && value.length < 5) {
      return 'Comment must be at least 5 characters';
    }

    if (value.length > 300) {
      return 'Comment is too long (max 300 characters)';
    }

    return null;
  }

  // General text validation
  static String? validateText(
    String? value, {
    required String fieldName,
    bool required = true,
    int minLength = 1,
    int maxLength = 255,
  }) {
    if (value == null || value.trim().isEmpty) {
      return required ? '$fieldName is required' : null;
    }

    value = value.trim();

    if (value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }

    if (value.length > maxLength) {
      return '$fieldName is too long (max $maxLength characters)';
    }

    return null;
  }

  // Utility method to clean phone number
  static String cleanPhoneNumber(String phone) {
    return phone
        .replaceAll(' ', '')
        .replaceAll('-', '')
        .replaceAll('(', '')
        .replaceAll(')', '');
  }

  // Utility method to format budget
  static String formatBudget(String budget) {
    final cleanBudget = budget
        .replaceAll(',', '')
        .replaceAll('PKR', '')
        .replaceAll('Rs', '')
        .trim();
    final amount = double.tryParse(cleanBudget);
    if (amount != null) {
      return amount.toStringAsFixed(0);
    }
    return cleanBudget;
  }

  // Check if string contains only numbers
  static bool isNumeric(String str) {
    return double.tryParse(str) != null;
  }

  // Sanitize input (remove HTML tags, trim spaces)
  static String sanitizeInput(String input) {
    return input
        .replaceAll(RegExp(r'<[^>]*>'), '') // Remove HTML tags
        .trim()
        .replaceAll(
          RegExp(r'\s+'),
          ' ',
        ); // Replace multiple spaces with single space
  }
}
