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

# Byte Beasts: Official Guide

The official Byte Beasts guide, the quickest and most streamlined way to get your Dojo provable game up and running. This guide will assist you with the initial setup, from cloning the repository to deploying your world.

Read the full tutorial [here](https://book.dojoengine.org/tutorial/dojo-starter).

## Running Locally

#### Terminal one (Make sure this is running)
```bash
# Run Katana
katana --disable-fee --allowed-origins "*"
```

#### Terminal two
```bash
# Build the example
sozo build

# Migrate the example
sozo migrate apply

# Start Torii
torii --world 0x70835f8344647b1e573fe7aeccbf044230089eb19624d3c7dea4080f5dcb025 --allowed-origins "*"
```

## Contribution

We welcome contributions from developers of all levels! If you're interested in contributing to this project, please follow our  [CONTRIBUTION GUIDELINES](./CONTRIBUTION.md) to get started.

Whether it's fixing bugs, improving documentation, or adding new features, your help is greatly appreciated. Don't hesitate to ask questions or reach out for support—we're here to help!
