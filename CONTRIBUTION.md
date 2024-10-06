<picture>
  <source media="(prefers-color-scheme: dark)" srcset=".github/mark-dark.svg">
  <img alt="Dojo logo" align="right" width="120" src=".github/mark-light.svg">
</picture>

<a href="https://twitter.com/dojostarknet">
<img src="https://img.shields.io/twitter/follow/dojostarknet?style=social"/>
</a>
<a href="https://github.com/dojoengine/dojo">
<img src="https://img.shields.io/github/stars/dojoengine/dojo?style=social"/>
</a>

[![discord](https://img.shields.io/badge/join-dojo-green?logo=discord&logoColor=white)](https://discord.gg/PwDa2mKhR4)
[![Telegram Chat][tg-badge]][tg-url]

[tg-badge]: https://img.shields.io/endpoint?color=neon&logo=telegram&label=chat&style=flat-square&url=https%3A%2F%2Ftg.sumanjay.workers.dev%2Fdojoengine
[tg-url]: https://t.me/dojoengine


# Contribution Guidelines
Thank you for considering contributing to this project! We appreciate your time and effort in improving our work. Below are the guidelines to help you contribute effectively,
but first, join our [Telegram](https://t.me/+-84e2pqLtqNkZDAx)!

# How to Contribute
### 1. Fork the Repository: 
Start by forking this repository to your GitHub account.

### 2. Clone the Repository:
After forking, clone the repository to your local machine:
``` bash
git clone https://github.com/your-user/ByteBeastsBackend.git
cd ByteBeastBackend
```

### 3. Create a New Branch:
Create a new branch for your feature or bug fix following the branch naming convention:
- For bugs: `bug-fix-name`
- For new features: `feat-name`
``` bash
git checkout -b feature-name
```

### 4. Make Changes:
Make your changes to the codebase. Ensure your code adheres to the project's coding style and standards. Make sure to add/update tests if needed.

### 5. Run Tests:
Before submitting your changes, run the existing test suite to ensure your code does not break anything:

Start the Katana environment
``` bash
# Run Katana
katana --disable-fee --allowed-origins "*"
```

``` bash
# Build the example
sozo build
```

``` bash 
# Run tests
sozo test
```

``` bash 
# Apply migrations
sozo migrate apply
```

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
