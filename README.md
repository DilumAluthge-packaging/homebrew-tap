# `dilumaluthge-packaging/tap` Homebrew Tap

This is a custom tap for the [Homebrew](https://brew.sh/) package manager.

Add the tap with:

```shell
brew tap dilumaluthge-packaging/tap

# Homebrew now requires users to manually trust each third-party tap:
brew trust dilumaluthge-packaging/tap
```

## Available formulas

| Name                                         | Formula                                  | License                                                                         | Installation Command                      | Notes   |
| -------------------------------------------- | ---------------------------------------- | ------------------------------------------------------------------------------- | ----------------------------------------- | ------- |
| [Pijul](https://pijul.org/) 1.0.0-beta       | [`pijul.rb`](./Formula/pijul.rb)         | [GPL-2.0](https://nest.pijul.com/pijul/pijul:main/DJ5JYH3KON2XO.BIAAA)          | `brew install dilumaluthge-packaging/tap/pijul`     | [1]     |
| [Platypus](https://sveinbjorn.org/platypus)  | [`platypus.rb`](./Formula/platypus.rb)   | [BSD-3-Clause](https://github.com/sveinbjornt/Platypus/blob/master/LICENSE.txt) | `brew install dilumaluthge-packaging/tap/platypus`  | [2] [3] |
| [shyaml-rs](https://github.com/0k/shyaml-rs) | [`shyaml-rs.rb`](./Formula/shyaml-rs.rb) | [MIT](https://github.com/0k/shyaml-rs/blob/main/LICENSE)                        | `brew install dilumaluthge-packaging/tap/shyaml-rs` | [4] [5] |

Notes:
1. A formula for Pijul previously existed upstream, but it [was removed on May 13, 2020](https://github.com/Homebrew/homebrew-core/commit/21702ef2c02ae7a5d925de7aed6defd0beefa93d).
2. A formula for Platypus previously existed upstream, but it [was removed on October 29, 2024](https://github.com/Homebrew/homebrew-core/commit/d72fd20fcf630707a97b23316c2789d1b46fecb2).
3. A deprecated cask for Platypus [exists upstream](https://formulae.brew.sh/cask/platypus). It is scheduled to be disabled on September 1, 2026.
4. As far as I can tell, a formula for `shyaml-rs` has never existed upstream.
5. A deprecated formula for the old `shyaml` (the Python-based one) [exists upstream](https://formulae.brew.sh/formula/shyaml). It was deprecated on October 26, 2025. It is scheduled to be disabled on October 26, 2026.

## Documentation

`brew help`, `man brew` or check [Homebrew's documentation](https://docs.brew.sh).
