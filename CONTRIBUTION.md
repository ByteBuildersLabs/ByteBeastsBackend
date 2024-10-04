# Contribution Guidelines
Thank you for considering contributing to this project! We appreciate your time and effort in improving our work. Below are the guidelines to help you contribute effectively, but first, join our [Telegram](https://t.me/+-84e2pqLtqNkZDAx)!

# How to Contribute

### 1. Fork the Repository:
Start by forking this repository to your GitHub account.

### 2. Clone the Repository:
After forking, clone the repository to your local machine:
```bash
git clone https://github.com/your-user/ByteBeastsBackend.git
cd ByteBeastBackend
```

### 3. Create a New Branch:
Create a new branch for your feature or bug fix following the branch naming convention:
- For bugs: `bug-fix-name`
- For new features: `feat-name`
```bash
git checkout -b feature-name
```

### 4. Make Changes:
Make your changes to the codebase. Ensure your code adheres to the project's coding style and standards. Make sure to add/update tests if needed.

### 5. Run Tests:
Before submitting your changes, run the following tests to ensure your code is working as expected:

1. **Build the project:**
   ```bash
   sozo build
   ```

2. **Run the test suite:**
   ```bash
   sozo test
   ```

3. **Deploy to Katana:**
   Finally, ensure the contract can be deployed successfully using Katana:
   ```bash
   sozo migrate apply
   ```

These three steps ensure that your code builds correctly, passes all tests, and can be deployed without issues. **Make sure all tests pass** before submitting your PR.

### 6. Commit Your Changes:
Use a descriptive commit message that explains your changes clearly.

### 7. Push to Your Fork:
Push your changes to your forked repository.

### 8. Submit a Pull Request:
Once your changes are ready, submit a Pull Request (PR) for review. Ensure that:
- Your PR has a clear and descriptive title.
- You provide a detailed explanation of the changes made.
- You reference any related issues (if applicable).

All contributions must go through the PR review process to maintain code quality and consistency. A project maintainer will review your PR and provide feedback or merge it into the main branch.
